defmodule CodeTogether.CodeRoomsController do
  use CodeTogether.Web, :controller
  alias CodeTogether.CodeRoom
  alias CodeTogether.Repo

  plug CodeTogether.Plug.Session when action in [:index, :new, :create, :show]

  def index(conn, _params) do
    username = get_session(conn, :username)
    render conn, "index.html", username: username, public_code_rooms: CodeRoom.all_public
  end

  def new(conn, _params) do
    username = get_session(conn, :username)
    changeset = CodeRoom.changeset(%CodeRoom{})
    render conn, "new.html", username: username, changeset: changeset
  end

  def create(conn, %{"code_room" => %{"name" => name,
                                      "language" => language,
                                      "private" => "true"}}) do
    case CodeRoom.create_private(name, String.downcase(language)) do
      {:ok, code_room} ->
        redirect conn, to: "/code_rooms/private/#{code_room.private_key}"
      {:error, :name_taken} ->
        IO.puts "name taken"
      other_error ->
      IO.inspect other_error
    end

  end

  def create(conn, %{"code_room" => %{"name" => name,
                                      "language" => language,
                                      "private" => "false"}}) do
    case CodeRoom.create_public(name, String.downcase(language)) do
      {:ok, code_room} ->
        redirect conn, to: "/code_rooms/public/#{code_room.name}"
      {:error, :name_taken} ->
        IO.puts "name taken"
      other_error ->
      IO.inspect other_error
    end

  end

  def show(conn, %{"private_key" => private_key}) do
    username = get_session conn, :username
    code_room = Repo.get_by CodeRoom, private_key: private_key
    unless CodeRoom.docker_is_running?(code_room), do: CodeRoom.start_docker(code_room)
    render conn, "code_room.html", code_room: code_room, username: username
  end

  def show(conn, %{"name" => name}) do
    username = get_session conn, :username
    code_room = Repo.get_by CodeRoom, name: name
    unless CodeRoom.docker_is_running?(code_room), do: CodeRoom.start_docker(code_room)
    render conn, "code_room.html", code_room: code_room, username: username
  end

  def validate_name(conn, %{"name" => name}) do
    case CodeRoom.validate_name(name) do
      {:error, error} -> json conn, %{error: error}
      {:ok, _} -> json conn, %{}
    end
  end

  def initial_data(conn, %{"id" => id}) do
    code_room = Repo.get CodeRoom, id
    json conn, %{language: code_room.language, code: code_room.code, output: code_room.output}
  end

end
