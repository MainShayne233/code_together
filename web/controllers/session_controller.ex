defmodule CodeTogether.SessionController do
  use CodeTogether.Web, :controller

  def create(conn, %{"username" => username}) do
    conn
    |> fetch_session
    |> put_session(:current_user, username)
    |> put_status(200)
    |> json(:ok)
  end

  def current_user(conn, _) do
    username = conn |> fetch_session |> get_session(:current_user)
    json conn, %{username: username}
  end
end
