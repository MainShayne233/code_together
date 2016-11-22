defmodule CodeTogether.Plug.Session do
  use CodeTogether.Web, :controller
  import Plug.Conn

  def init(default), do: default

  # redirectes user to create username if they haven't already
  def call(conn, _) do
    case get_session(conn, :username) do
      nil ->
        conn
        |> redirect(to: "/session/new")
        |> halt
      _ ->
      conn
    end
  end
  
end
