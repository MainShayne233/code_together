defmodule CodeTogether.CodeRoomChannel do
  use Phoenix.Channel
  alias CodeTogether.DockerImage
  require Logger

  def join("code_room:connect", _messaage, socket) do
    {:ok, socket}
  end

  def handle_in("code_room:run", %{"code" => code, "token" => token}, socket) do
    case Phoenix.Token.verify(socket, "username", token) do
      {:ok, username} ->
        result = DockerImage.result_for(code, username)
        broadcast! socket, "code_room:output_update", %{output: result}
      _ ->
        IO.puts "invalid token"
    end
    {:noreply, socket}
  end


end
