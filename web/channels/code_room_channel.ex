defmodule CodeTogether.CodeRoomChannel do
  use Phoenix.Channel
  alias CodeTogether.CodeRoom
  alias CodeTogether.Repo
  require Logger

  intercept [
    "code_room:code_update",
    "code_room:output_update",
    "code_room:not_ready",
    "code_room:ready"
  ]

  def join("code_room:connect", %{"code_room_id" => code_room_id}, socket) do
    socket = assign(socket, :code_room_id, code_room_id)
    {:ok, socket}
  end

  def handle_in("code_room:prepare", _message, socket) do
    code_room_id = socket.assigns[:code_room_id]
    code_room = Repo.get! CodeRoom, code_room_id
    CodeRoom.notify_when_running(code_room, socket)
    {:noreply, socket}
  end

  def handle_in("code_room:new_code", %{"code" => code, "username" => username}, socket) do
    code_room_id = socket.assigns[:code_room_id]
    code_room = Repo.get! CodeRoom, code_room_id
    data = %{code: code, code_room_id: code_room_id, username: username}
    broadcast! socket, "code_room:code_update", data
    CodeRoom.update(code_room, %{code: code})
    {:noreply, socket}
  end

  def handle_out(room_and_topic, payload, socket) do
    user_code_room_id = socket.assigns[:code_room_id]
    if payload.code_room_id == user_code_room_id do
      push socket, room_and_topic, payload
    end
    {:noreply, socket}
  end

  def handle_in("code_room:run", %{"code" => code}, socket) do
    code_room_id = socket.assigns[:code_room_id]
    code_room = Repo.get! CodeRoom, code_room_id
    result = CodeRoom.result_for(code_room, code)
    updated_output = CodeRoom.truncate(code_room.output <> "\n" <> result)
    broadcast! socket, "code_room:output_update", %{output: updated_output, code_room_id: code_room_id}
    unless CodeRoom.in_good_standing?(code_room), do: CodeRoom.reset_and_notify(code_room, socket)
    CodeRoom.update(code_room, %{output: updated_output})
    {:noreply, socket}
  end

end
