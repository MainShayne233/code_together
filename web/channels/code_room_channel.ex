defmodule CodeTogether.CodeRoomChannel do
  use Phoenix.Channel
  alias CodeTogether.CodeRoom
  alias CodeTogether.Repo
  require Logger


  def join("code_room:connect", _message, socket) do
    {:ok, socket}
  end

  def handle_in("code_room:prepare", %{"code_room_id" => code_room_id}, socket) do
    code_room = Repo.get! CodeRoom, code_room_id
    CodeRoom.notify_when_running(code_room, socket)
    {:noreply, socket}
  end

  def handle_in("code_room:new_code", %{"code" => code, "code_room_id" => code_room_id, "username" => username}, socket) do
    code_room = Repo.get! CodeRoom, code_room_id
    broadcast! socket, "code_room:code_update", %{code: code, code_room_id: code_room_id, username: username}
    CodeRoom.update(code_room, %{code: code})
    {:noreply, socket}
  end

  def handle_in("code_room:run", %{"code" => code, "code_room_id" => code_room_id}, socket) do
    code_room = Repo.get! CodeRoom, code_room_id
    result = CodeRoom.result_for(code_room, code)
    updated_output = CodeRoom.truncate(code_room.output <> "\n" <> result)
    broadcast! socket, "code_room:output_update", %{output: updated_output, code_room_id: code_room_id}
    unless CodeRoom.in_good_standing?(code_room), do: CodeRoom.reset_and_notify(code_room, socket)
    CodeRoom.update(code_room, %{output: updated_output})
    {:noreply, socket}
  end

end
