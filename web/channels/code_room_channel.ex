defmodule CodeTogether.CodeRoomChannel do
  use Phoenix.Channel
  require Logger

  def join("code_room:connect", _messaage, socket) do
    {:ok, socket}
  end


end
