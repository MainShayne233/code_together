defmodule CodeTogether.CodeRoom do
  alias CodeTogether.CodeRoom
  alias CodeTogether.Repo
  alias CodeTogether.Language
  use CodeTogether.Web, :model
  use Phoenix.Channel
  import Ecto.Query

  schema "code_rooms" do
    field :language,      :string
    field :name,          :string
    field :private_key,   :string
    field :code,          :string
    field :output,        :string
    field :docker_name,   :string
    field :port,          :integer
    field :current_users, {:array, :string}
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, all_fields)
    |> validate_required(all_fields -- [:private_key, :code])
  end

  def all_fields do
    [
      :language,
      :name,
      :code,
      :output,
      :private_key,
      :docker_name,
      :port,
      :current_users
    ]
  end

  def validate_uniq(value, field) do
    case Repo.get_by(CodeRoom, %{field => value}) do
      nil -> nil
      _   -> "There is already a code room with a #{field}: #{value}"
    end
  end

  def validate_length(value, field) do
    {min, max} = valid_lengths_for(field)
    cond do
      String.length(value) < min ->
        "#{field} must at least #{min} character(s) in length"
      String.length(value) > max ->
        "#{field} cannot exceed #{max} character(s) in length"
      true ->
        nil
    end
  end

  def validate_presence(value, field) do
    if value && value != "", do: nil, else: "#{field} is a required field"
  end

  def valid_lengths_for(:name), do: {1, 50}

  def validations(code_room) do
    [
      validate_presence(code_room["name"], :name),
      validate_uniq(code_room["name"], :name),
      validate_length(code_room["name"], :name),
      validate_presence(code_room["language"], :language),
    ]
    |> Enum.filter( &(&1) )
  end

  def create_coderoom(code_room_params) do
    case validations(code_room_params) do
      [] ->
        %{"name" => name, "language" => language, "private" => private} = code_room_params
        {:ok, code_room} = %CodeRoom{}
        |> changeset(%{
          name:          name,
          language:      language,
          private_key:   (if private, do: new_private_key, else: nil),
          code:          Language.default_code_for(language),
          output:        Language.default_output_for(language),
          docker_name:   new_docker_name,
          port:          new_port,
          current_users: []
        })
        |> Repo.insert
        start_docker(code_room)
        {:ok, (if private, do: code_room.private_key, else: name)}
      errors ->
        {:error, errors}
    end
  end

  def all_public do
    (from c in CodeRoom,
    where: is_nil(c.private_key))
    |> Repo.all
  end

  def update(code_room, params) do
    changeset(code_room, params)
    |> Repo.update
  end

  def get(%{"private" => true, "name" => key}) do
    Repo.get_by(CodeRoom, private_key: key)
  end

  def get(%{"private" => false, "name" => name}) do
    Repo.get_by(CodeRoom, name: name)
  end

  def get(id) do
    Repo.get CodeRoom, id
  end

  def close(code_room) do
    spawn fn ->
      docker_cmd ["stop", code_room.docker_name]
      docker_cmd ["rm",   code_room.docker_name]
      Repo.delete code_room
    end
  end

  def close_inactive_rooms do
    inactive_rooms
    |> Enum.each(fn code_room ->
      IO.puts "Closing coderoom #{code_room.id} due to inactivity"
      close code_room
    end)
  end

  def inactive_rooms do
    (from c in CodeRoom,
    where: c.updated_at < ^fifteen_minutes_ago)
    |> Repo.all
  end

  def fifteen_minutes_ago do
    Calendar.DateTime.now_utc
    |> Calendar.DateTime.subtract!(60 * 15)
    |> Calendar.DateTime.to_erl
    |> Ecto.DateTime.from_erl
  end

  def add_user_and_notify_if_new(code_room, username, socket) do
    spawn fn ->
      unless Enum.find(code_room.current_users, &( &1 == username ) ) do
        current_users = code_room.current_users ++ [username]
        update_current_users(code_room, current_users, socket)
      end
    end
    code_room
  end

  def update_current_users(code_room, current_users, socket) do
    data = %{code_room_id: code_room.id, current_users: current_users}
    broadcast! socket, "code_room:update_users", data
    changeset(code_room, %{current_users: current_users})
    |> Repo.update
  end

  def handle_leaving_user(code_room, leaving_user, socket) do
    current_users = code_room.current_users -- [leaving_user]
    update_current_users(code_room, current_users, socket)
  end

  def truncate(output) do
    character_count = String.length output
    if character_count > max_output_char_count do
      String.slice(output, character_count - max_output_char_count, character_count)
    else
      output
    end
  end

  def max_output_char_count, do: 6000

  def available?(name) do
    Repo.get_by(CodeRoom, name: name) == nil
  end

  def taken?(name) do
    !available?(name)
  end

  def new_private_key do
    :os.system_time(:micro_seconds)
    |> Integer.to_string
  end

  def result_for(code_room, code) do
    execute code_room, code
  end

  def reset_and_notify(code_room, socket) do
    reset_docker_container!(code_room)
    notify_when_running(code_room, socket, "Dev environment was corrupted. Resetting now.")
  end

  def notify_when_running(code_room, socket, message \\ "Setting up dev environment") do
    spawn fn ->
      if docker_is_running?(code_room) do
        broadcast! socket, "code_room:ready", %{code_room_id: code_room.id}
      else
        data = %{message: message, code_room_id: code_room.id}
        broadcast! socket, "code_room:not_ready", data
        :timer.sleep(500)
        notify_when_running code_room, socket
      end
    end
    code_room
  end

  def build_image! do
    IO.puts "building docker image"
    docker_cmd ["build", "-t", "code_exe_api", "./code_exe_api"]
  end

  def docker_is_running?(code_room) do
    execute(code_room, "'working'")
    |> String.contains?("working")
  end

  def start_docker(code_room) do
    spawn fn ->
      docker_cmd [
        "run",
        "-p",
        "#{code_room.port}:8080",
        "-d",
        "--name",
        "#{code_room.docker_name}",
        "code_exe_api"
       ]
       IO.puts "Started #{code_room.docker_name} on port #{code_room.port}"
    end
    code_room
  end

  def execute(code_room, code \\ "") do
    "localhost:#{code_room.port}/api/v1/code/execute"
    |> HTTPotion.post(
      body: Poison.encode!(%{code: code, language: code_room.language}),
      headers: ["Content-Type": "application/json"],
    )
    |> case do
      %HTTPotion.Response{status_code: 200, body: body} -> body
      %HTTPotion.Response{status_code: 500, body: body} -> "There was an issue executing the code"
      %HTTPotion.ErrorResponse{message: message} -> message
    end
    |> Poison.decode
    |> case do
      {:ok, %{"result" => result}} -> result
      {:error, _} -> "There was an issue executing the code"
    end
  end

  def new_docker_name do
    :os.system_time(:micro_seconds)
    |> Integer.to_string
  end

  def new_port do
    current_max_port + 1
  end

  def current_max_port do
    case current_ports do
      [] -> 8081
      ports -> Enum.max(ports)
    end
  end

  def current_ports do
    Repo.all(CodeRoom)
    |> Enum.map(&(&1.port))
  end

  def reset_docker_container!(code_room) do
    spawn fn ->
      docker_cmd ["stop", code_room.docker_name]
      docker_cmd ["rm",   code_room.docker_name]
      start_docker code_room
    end
    code_room
  end

  def docker_cmd(args) do
    System.cmd "docker", args
  end

  def delete_all! do
    Repo.delete_all CodeRoom
  end

  def all do
    Repo.all CodeTogether.CodeRoom
  end

end
