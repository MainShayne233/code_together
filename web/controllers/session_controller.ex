defmodule CodeTogether.SessionController do
  use CodeTogether.Web, :controller
  alias CodeTogether.{User}

  def create(conn, %{"username" => username}) do
    User.create(username)
    |> case do
      {:ok, %{username: username}} ->
        conn
        |> fetch_session
        |> put_session(:current_user, username)
        |> json(:ok)
      {:error, errors} ->
        conn
        |> fetch_session
        |> json(%{errors: errors})
    end
  end

  def current_user(conn, _) do
     conn
     |> fetch_session
     |> get_session(:current_user)
     |> User.get
     |> case do
       {:ok, %{username: username}} ->
         conn
         |> json(%{username: username})
       {:error, error} ->
         conn
         |> json(%{error: error})
     end
  end
end
