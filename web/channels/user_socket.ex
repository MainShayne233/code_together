defmodule CodeTogether.UserSocket do
  use Phoenix.Socket

  channel "code_room:*", CodeTogether.CodeRoomChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_params, socket) do
    IO.puts "CONNECT"
    {:ok, socket}
  end

  def id(_socket), do: nil
end
