defmodule CodeTogether.SessionController do
  use CodeTogether.Web, :controller

  def start(conn, _params) do
    case current_username(conn) do
      nil -> redirect conn, to: "/session/new"
      user -> redirect conn, to: "/code_rooms"
    end
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"username" => username}) do
    conn = put_session conn, :username, username
    redirect conn, to: "/code_rooms"
  end

  def current_username(conn) do
    get_session conn, :username
  end
end
