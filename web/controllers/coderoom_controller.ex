defmodule CodeTogether.CoderoomController do
  use CodeTogether.Web, :controller

  alias CodeTogether.{CodeRoom, Util}

  def get(conn, %{"id" => id}) do
    case CodeRoom.get_by(%{id: id}) do
      nil ->
        json conn, %{error: "failed to get coderoom"}
      coderoom ->
        json conn, CodeRoom.for_json(coderoom)
    end
  end

  def get(conn, %{"name" => name}) do
    case CodeRoom.get_by(%{name: name}) do
      coderoom = %{private_key: nil} ->
        json conn, CodeRoom.for_json(coderoom)
      _ ->
        conn |> put_status(400) |> json( %{error: "failed to get coderoom"})
     end
  end

  def get(conn, %{"private_key" => private_key}) do
    case CodeRoom.get_by(%{private_key: private_key || ""}) do
      nil ->
        conn |> put_status(400) |> json(%{error: "failed to get coderoom"})
      coderoom ->
        conn |> put_status(200) |> json(CodeRoom.for_json(coderoom))
    end
  end

  def all_public(conn, _) do
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

  def create(conn, %{"coderoom" => coderoom_params}) do
    coderoom_params
    |> Util.atomize_map
    |> CodeRoom.create_coderoom
    |> case do
      {:ok, coderoom} ->
        json conn, CodeRoom.for_json(coderoom)
      {:error, _changeset} ->
        conn |> put_status(400) |> json(%{error: "Failed to create coderoom"})
    end
  end

  def start(conn, %{"id" => id}) do
    case CodeRoom.get_by(%{id: id}) do
      nil ->
        conn |> put_status(400) |> json(%{error: "Failed to start coderoom"})
      coderoom ->
        if CodeRoom.docker_is_running?(coderoom) do
          conn |> json(%{success: "Coderoom already running"})
        else
          CodeRoom.start_docker(coderoom)
          conn |> json(%{success: "Successfully started coderoom"})
        end
    end
  end

end
