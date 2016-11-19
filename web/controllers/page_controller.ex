defmodule CodeTogether.PageController do
  use CodeTogether.Web, :controller

  def index(conn, _params) do
    IO.inspect get_session(conn, :username)
    render conn, "index.html", username: get_session(conn, :username)
  end
end
