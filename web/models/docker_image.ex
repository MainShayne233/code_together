defmodule CodeTogether.DockerImage do
  alias CodeTogether.DockerImage
  alias CodeTogether.Repo
  use CodeTogether.Web, :model
  import Ecto.Query

  schema "docker_images" do
    field :port, :integer
    field :name, :string
    field :username, :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:port, :name, :username])
    |> validate_required([:port, :name, :username])
  end

  def username_available?(username) do
    find_for(username) == []
  end

  def find_for(username) do
    Repo.all(
      from d in DockerImage,
      where: d.username == ^username
    )
  end

  def create_for(username) do
    {:ok, docker_image} = %DockerImage{}
    |> changeset(new_image_params(username))
    |> Repo.insert
    run docker_image
    docker_image.id
  end

  def run(docker_image) do
    spawn (fn ->
      docker_cmd [
        "run",
        "-p",
        "#{docker_image.port}:8080",
        "-d",
        "--name",
        "#{docker_image.name}",
        "code_exe_api"
       ]
       IO.puts "Started #{docker_image.name} on port #{docker_image.port}"
    end)
  end

  def new_image_params(username) do
    %{
      name: new_name,
      port: new_port,
      username: username
    }
  end

  def new_name do
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
    Repo.all(DockerImage)
    |> Enum.map(&(&1.port))
  end

  def kill_all do
    case all_running do
      [] -> IO.puts "No images to kill"
      image_names -> kill_many image_names
    end
  end

  def kill_many images do
    spawn fn ->
      docker_cmd ["stop"] ++ images
      docker_cmd ["rm"] ++ images
      IO.puts "Killed: #{Enum.join(images, ", ")}"
    end
  end

  def delete_all do
    Repo.delete_all DockerImage
  end

  def all_running do
    { response, _ } = docker_cmd(["ps", "-a", "-q"])
    String.split(response, "\n")
    |> Enum.filter(&( &1 != "" ))
  end

  def docker_cmd(args) do
    System.cmd "docker", args
  end

end
