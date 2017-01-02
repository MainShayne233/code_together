defmodule CodeTogether.Coderoom do
  alias CodeTogether.{Coderoom, Repo, Language}
  use CodeTogether.Web, :model
  use Phoenix.Channel
  import Ecto.Query

  schema "coderooms" do
    field :language,      :string
    field :name,          :string
    field :private_key,   :string
    field :code,          :string
    field :output,        :string
    field :chat,          :string
    field :docker_name,   :string
    field :port,          :integer
    field :current_users, {:array, :string}
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, all_fields)
    |> validate_required(all_fields -- [:private_key, :code, :chat])
    |> unique_constraint(:name)
    |> unique_constraint(:private_key)
    |> unique_constraint(:docker_name)
    |> unique_constraint(:port)

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
      :current_users,
      :chat
    ]
  end

  def create(coderoom_params) do
    %Coderoom{}
    |> changeset(sanitized_params(coderoom_params))
    |> Repo.insert
    |> case do
      {:ok, coderoom} -> {:ok, coderoom}
      {:error, errors} -> {:error, errors}
    end
  end

  def sanitized_params(coderoom_params) do
    coderoom_params
    |> Map.take([:name, :language])
    |> Map.merge(%{
      private_key:   (if Map.get(coderoom_params, :private), do: new_private_key, else: nil),
      code:          Language.default_code_for(coderoom_params.language),
      output:        Language.default_output_for(coderoom_params.language),
      chat:          " ",
      docker_name:   new_docker_name,
      port:          new_port,
      current_users: []
    })
  end

  def all_public do
    (from c in Coderoom,
    where: is_nil(c.private_key))
    |> Repo.all
  end

  def update(coderoom, params) do
    changeset(coderoom, params)
    |> Repo.update
  end

  def get_by(params) do
    Repo.get_by Coderoom, params
  end

  def for_json(coderoom) do
    coderoom
    |> Map.take([:name, :id, :code, :output, :current_users, :chat])
  end

  def close(coderoom) do
    spawn fn ->
      docker_cmd ["stop", coderoom.docker_name]
      docker_cmd ["rm",   coderoom.docker_name]
      Repo.delete coderoom
    end
  end

  def close_inactive_rooms do
    inactive_rooms
    |> Enum.each(fn coderoom ->
      IO.puts "Closing coderoom #{coderoom.id} due to inactivity"
      close coderoom
    end)
  end

  def inactive_rooms do
    (from c in Coderoom,
    where: c.updated_at < ^fifteen_minutes_ago)
    |> Repo.all
  end

  def fifteen_minutes_ago do
    Calendar.DateTime.now_utc
    |> Calendar.DateTime.subtract!(60 * 15)
    |> Calendar.DateTime.to_erl
    |> Ecto.DateTime.from_erl
  end

  def add_user_and_notify_if_new(coderoom, username, socket) do
    spawn fn ->
      unless Enum.find(coderoom.current_users, &( &1 == username ) ) do
        current_users = coderoom.current_users ++ [username]
        update_current_users(coderoom, current_users, socket)
      end
    end
    coderoom
  end

  def update_current_users(coderoom, current_users, socket) do
    data = %{coderoom_id: coderoom.id, current_users: current_users}
    broadcast! socket, "coderoom:update_users", data
    changeset(coderoom, %{current_users: current_users})
    |> Repo.update
  end

  def handle_leaving_user(coderoom, leaving_user, socket) do
    current_users = coderoom.current_users -- [leaving_user]
    update_current_users(coderoom, current_users, socket)
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
    Repo.get_by(Coderoom, name: name) == nil
  end

  def taken?(name) do
    !available?(name)
  end

  def new_private_key do
    :os.system_time(:micro_seconds)
    |> Integer.to_string
  end

  def result_for(coderoom, code) do
    execute coderoom, code
  end

  def reset_and_notify(coderoom, socket) do
    reset_docker_container!(coderoom)
    notify_when_running(coderoom, socket, "Dev environment was corrupted. Resetting now.")
  end

  def notify_when_running(coderoom, socket, message \\ "Setting up dev environment") do
    spawn fn ->
      if docker_is_running?(coderoom) do
        broadcast! socket, "coderoom:ready", %{coderoom_id: coderoom.id}
      else
        data = %{message: message, coderoom_id: coderoom.id}
        broadcast! socket, "coderoom:not_ready", data
        :timer.sleep(500)
        notify_when_running coderoom, socket
      end
    end
    coderoom
  end

  def build_image! do
    IO.puts "building docker image"
    docker_cmd ["build", "-t", "code_exe_api", "./code_exe_api"]
  end

  def docker_is_running?(coderoom) do
    execute(coderoom, "'working'")
    |> String.contains?("working")
  end

  def start_docker(coderoom) do
    spawn fn ->
      {output, _} = docker_cmd(["ps", "-a"])
      if String.contains?(output, coderoom.docker_name) do
        docker_cmd ["start", "#{coderoom.docker_name}"]
      else
        docker_cmd [
          "run",
          "-p",
          "#{coderoom.port}:8080",
          "-d",
          "--name",
          "#{coderoom.docker_name}",
          "code_exe_api"
         ]
      end
       IO.puts "Started #{coderoom.docker_name} on port #{coderoom.port}"
    end
    coderoom
  end

  def execute(coderoom, code \\ "") do
    "localhost:#{coderoom.port}/api/v1/code/execute"
    |> HTTPotion.post(
      body: Poison.encode!(%{code: code, language: coderoom.language}),
      headers: ["Content-Type": "application/json"],
    )
    |> case do
      %HTTPotion.Response{status_code: 200, body: body} -> body
      %HTTPotion.Response{status_code: 500} -> "There was an issue executing the code"
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
    Repo.all(Coderoom)
    |> Enum.map(&(&1.port))
  end

  def reset_docker_container!(coderoom) do
    spawn fn ->
      docker_cmd ["stop", coderoom.docker_name]
      docker_cmd ["rm",   coderoom.docker_name]
      start_docker coderoom
    end
    coderoom
  end

  def docker_cmd(args) do
    System.cmd "docker", args
  end

  def delete_all! do
    Repo.delete_all Coderoom
  end

  def all do
    Repo.all CodeTogether.Coderoom
  end

end
