defmodule CodeTogether.CodeRoom do
  alias CodeTogether.CodeRoom
  alias CodeTogether.Repo
  use CodeTogether.Web, :model
  use Phoenix.Channel

  schema "code_rooms" do
    field :language,    :string
    field :name,        :string
    field :private_key, :string
    field :code,        :string
    field :output,      :string
    field :docker_name, :string
    field :port,        :integer
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:language, :name, :code, :output, :private_key, :docker_name, :port])
    |> validate_required([:language, :name, :code, :output, :private_key, :docker_name, :port])
  end

  def validate_name(name) do
    [
      validate_uniq(name, :name),
      validate_length(name, :name)
    ]
    |> validity_check
  end

  def validity_check(validations) do
    case error_list(validations) do
      [] -> {:ok, "valid"}
      errors -> {:error, errors}
    end
  end

  def error_list(validations) do
    Enum.filter_map(validations, fn (validation) ->
      case validation do
        {:error, _} -> true
        _ -> false
      end
    end,
    fn (error) ->
      {:error, message} = error
      message
    end)
  end

  def validate_uniq(value, field) do
    case Repo.get_by(CodeRoom, %{field => value}) do
      nil -> {:ok, "#{field} is uniq"}
      _   -> {:error, "There is already a code room with a #{field}: #{value}"}
    end
  end

  def validate_length(value, field) do
    {min, max} = valid_lengths_for(field)
    cond do
      String.length(value) < min ->
        {:error, "#{field} must at least #{min} character(s) in length"}
      String.length(value) > max ->
        {:error, "#{field} cannot exceed #{max} character(s) in length"}
      true ->
        {:ok, "#{field} is of proper length"}
    end
  end

  def valid_lengths_for(:name), do: {1, 50}

  def create_private(name, language) do
    if available?(name) do
      %CodeRoom{}
      |> changeset(%{
        name:        name,
        language:    language,
        private_key: new_private_key,
        code:        default_code_for(language),
        output:      default_output_for(language),
        docker_name: new_docker_name,
        port:        new_port
      })
      |> Repo.insert
      |> IO.inspect
    else
      {:error, :name_taken}
    end
  end

  def update(code_room, params) do
    changeset(code_room,params)
    |> Repo.update
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
  end

  def in_good_standing?(code_room) do
    docker_is_running? code_room
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
    spawn (fn ->
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
    end)
  end

  def execute(code_room, code) do
    result = "localhost:#{code_room.port}/api/ruby/run"
    |> HTTPotion.get(query: %{code: code})
    |> Map.get(:body)

    case Poison.decode(result || "") do
      {:ok, response} -> response
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
    IO.puts "current ports"
    Repo.all(CodeRoom)
    |> Enum.map(&(&1.port))
  end

  def reset_docker_container!(code_room) do
    spawn fn ->
      docker_cmd ["stop", code_room.docker_name]
      docker_cmd ["rm",   code_room.docker_name]
      start_docker code_room
    end
  end

  def docker_cmd(args) do
    System.cmd "docker", args
  end

  def default_code_for("ruby") do
    "class String\n  "         <>
    "def palindrome?\n    "    <>
    "self == self.reverse\n  " <>
    "end\nend\n\n'racecar'.palindrome?"
  end

  def delete_all! do
    Repo.delete_all CodeRoom
  end

  def default_output_for("ruby"), do: "=> true"
end
