defmodule CodeTogether.CodeRoomsController do
  use CodeTogether.Web, :controller
  alias CodeTogether.CodeRoom
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
    case CodeRoom.create_private(name, language) do
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
    token = Phoenix.Token.sign(conn, "username", username)
    code_room = Repo.get CodeRoom, id
    render conn, "code_room.html", code_room: code_room, token: token
  end

end
