defmodule CodeTogether.CodeRoomsController do
  use CodeTogether.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", username: get_session(conn, :username)
  end
end
