defmodule CodeTogether.CoderoomChannel do
  use Phoenix.Channel
  alias CodeTogether.Coderoom
  require Logger

  intercept [
    "coderoom:code_update",
    "coderoom:output_update",
    "coderoom:not_ready",
    "coderoom:ready"
  ]

  def join("coderoom:connect", %{"coderoom_id" => coderoom_id}, socket) do
    socket = assign(socket, :coderoom_id, coderoom_id)
    {:ok, socket}
  end

  def terminate(_reason, socket) do
    leaving_user = socket.assigns[:username]
    socket.assigns[:coderoom_id]
    |> Coderoom.get_by
    |> Coderoom.handle_leaving_user(leaving_user, socket)
  end

  def handle_in("coderoom:prepare", %{"username" => username}, socket) do
    socket = assign(socket, :username, username)
    socket.assigns[:coderoom_id]
    |> Coderoom.get_by
    |> Coderoom.notify_when_running(socket)
    |> Coderoom.add_user_and_notify_if_new(username, socket)
    {:noreply, socket}
  end

  def handle_in("coderoom:new_code", %{"code" => code, "username" => username}, socket) do
    coderoom_id = socket.assigns[:coderoom_id]
    data = %{code: code, coderoom_id: coderoom_id, username: username}
    broadcast! socket, "coderoom:code_update", data
    Coderoom.get_by(coderoom_id)
    |> Coderoom.update(%{code: code})
    {:noreply, socket}
  end

  def handle_in("coderoom:new_chat", %{"new_chat" => new_chat}, socket) do
    coderoom_id = socket.assigns[:coderoom_id]
    coderoom = Coderoom.get_by(coderoom_id)
    updated_chat = (coderoom.chat <> "\n" <> new_chat) |> Coderoom.truncate
    broadcast! socket, "coderoom:chat_update", %{chat: updated_chat}
    Coderoom.update(coderoom, %{chat: updated_chat})
    {:noreply, socket}
  end

  def handle_out(room_and_topic, payload, socket) do
    user_coderoom_id = socket.assigns[:coderoom_id]
    if payload.coderoom_id == user_coderoom_id do
      push socket, room_and_topic, payload
    end
    {:noreply, socket}
  end

  def handle_in("coderoom:run", %{"code" => code}, socket) do
    coderoom_id = socket.assigns[:coderoom_id]
    coderoom = Coderoom.get_by coderoom_id
    result = Coderoom.result_for(coderoom, code)
    updated_output = Coderoom.truncate(coderoom.output <> "\n" <> result)
    broadcast! socket, "coderoom:output_update", %{output: updated_output, coderoom_id: coderoom_id}
    unless Coderoom.docker_is_running?(coderoom), do: Coderoom.reset_and_notify(coderoom, socket)
    Coderoom.update(coderoom, %{output: updated_output})
    {:noreply, socket}
  end

end
