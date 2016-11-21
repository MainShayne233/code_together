defmodule CodeTogether.CodeRoomsController do
  use CodeTogether.Web, :controller
  alias CodeTogether.CodeRoom
  alias CodeTogether.DockerImage
  alias CodeTogether.Repo

  def index(conn, _params) do
    username = get_session(conn, :username)
    render conn, "index.html", username: username
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

        redirect conn, to: code_rooms_path(conn, :show, code_room)
      {:error, :name_taken} ->
        IO.puts "name taken"
      _ ->
      IO.puts "other error"
    end

  end

  def show(conn, %{"id" => id}) do
    username = get_session conn, :username
    code_room = Repo.get CodeRoom, id
    DockerImage.find_for(code_room) || DockerImage.create_for(code_room)
    render conn, "code_room.html", code_room: code_room, username: username
  end

  def initial_data(conn, %{"id" => id}) do
    code_room = Repo.get CodeRoom, id
    json conn, %{language: code_room.language, code: code_room.code, output: code_room.output}
  end

end
