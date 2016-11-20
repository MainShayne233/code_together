defmodule CodeTogether.CodeRoomsController do
  use CodeTogether.Web, :controller

  def index(conn, _params) do
    username = get_session(conn, :username)
    token = Phoenix.Token.sign(conn, "username", username)
    render conn, "index.html", username: username, token: token
  end
end
