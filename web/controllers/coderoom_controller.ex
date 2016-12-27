defmodule CodeTogether.CoderoomController do
  use CodeTogether.Web, :controller

  alias CodeTogether.CodeRoom

  def create(conn, coderoom = %{"private" => private}) do
    case CodeRoom.create_coderoom(coderoom) do
      {:ok, name} ->
        json conn, %{name: name}
      {:error, error} ->
        json conn, %{error: error}
    end
  end

  def get_all(conn, _) do
    coderooms = CodeRoom.all_public
    |> Enum.map(fn coderoom ->
      %{
        name: coderoom.name,
        language: coderoom.language,
        current_users: coderoom.current_users,
      }
    end)
    json conn, %{coderooms: coderooms}
  end

  def get(conn, coderoom_params) do
    case CodeRoom.get(coderoom_params) do
      coderoom = %{name: name} ->
        json conn, Map.take(coderoom, [:name, :id, :code, :output, :current_users, :chat])
      _ ->
        json conn, %{error: "failed to get coderoom"}
    end
  end

  def start(conn, coderoom_params) do
    IO.puts "starting"
    case CodeRoom.get(coderoom_params) do
      coderoom = %{name: name} ->
        unless CodeRoom.docker_is_running?(coderoom) do
          CodeRoom.start_docker(coderoom)
        end
        json conn, %{status: 200}
      _ ->
        json conn, %{status: 400}
    end
  end

end
