defmodule CodeTogether.CodeRoomChannel do
  use Phoenix.Channel
  alias CodeTogether.DockerImage
  alias CodeTogether.CodeRoom
  alias CodeTogether.Repo
  require Logger

  intercept ["code_room:output_update"]

  def join("code_room:connect", _messaage, socket) do
    {:ok, socket}
  end

  def handle_in("code_room:run", %{"code" => code, "token" => token}, socket) do
    case Phoenix.Token.verify(socket, "code_room_id", token) do
      {:ok, code_room_id} ->
        code_room = Repo.get! CodeRoom, code_room_id
        result = DockerImage.result_for(code, code_room)
        broadcast! socket, "code_room:output_update", %{output: result}
      _ ->
        IO.puts "invalid token"
    end
    {:noreply, socket}
  end

  def handle_out("code_room:output_update", payload, socket) do
    IO.puts "handle_out"
    push socket, "code_room:output_update", payload
    {:noreply, socket}
  end

end
