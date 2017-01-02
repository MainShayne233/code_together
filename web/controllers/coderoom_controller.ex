defmodule CodeTogether.CoderoomController do
  use CodeTogether.Web, :controller

  alias CodeTogether.{Coderoom, Util}

  def get(conn, %{"id" => id}) do
    case Coderoom.get_by(%{id: id}) do
      nil ->
        json conn, %{error: "failed to get coderoom"}
      coderoom ->
        json conn, Coderoom.for_json(coderoom)
    end
  end

  def get(conn, %{"name" => name}) do
    case Coderoom.get_by(%{name: name}) do
      coderoom = %{private_key: nil} ->
        json conn, Coderoom.for_json(coderoom)
      _ ->
        conn |> put_status(400) |> json( %{error: "failed to get coderoom"})
     end
  end

  def get(conn, %{"private_key" => private_key}) do
    case Coderoom.get_by(%{private_key: private_key || ""}) do
      nil ->
        conn |> put_status(400) |> json(%{error: "failed to get coderoom"})
      coderoom ->
        conn |> put_status(200) |> json(Coderoom.for_json(coderoom))
    end
  end

  def all_public(conn, _) do
    coderooms = Coderoom.all_public
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
    |> Coderoom.create
    |> case do
      {:ok, coderoom} ->
        json conn, Coderoom.for_json(coderoom)
      {:error, _changeset} ->
        conn |> put_status(400) |> json(%{error: "Failed to create coderoom"})
    end
  end

  def start(conn, %{"id" => id}) do
    case Coderoom.get_by(%{id: id}) do
      nil ->
        conn |> put_status(400) |> json(%{error: "Failed to start coderoom"})
      coderoom ->
        if Coderoom.docker_is_running?(coderoom) do
          conn |> json(%{success: "Coderoom already running"})
        else
          Coderoom.start_docker(coderoom)
          conn |> json(%{success: "Successfully started coderoom"})
        end
    end
  end

end
