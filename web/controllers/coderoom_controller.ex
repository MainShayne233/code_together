defmodule CodeTogether.CoderoomController do
  use CodeTogether.Web, :controller

  def create(conn, coderoom = %{"private" => private}) do
    case CodeTogether.CodeRoom.create_coderoom(coderoom) do
      {:ok, name} ->
        json conn, %{name: name}
      {:error, error} ->
        json conn, %{error: "Failed to create coderoom"}
    end
  end

  def get(conn, coderoom_params) do
    case CodeTogether.CodeRoom.get(coderoom_params) do
      %{name: name, id: id, language: language} ->
        json conn, %{name: name, id: id, language: language}
      _ ->
        json conn, %{error: "failed to get coderoom"}
    end
  end

end
