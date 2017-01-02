defmodule CodeTogether.RoomWatcher do
  use GenServer
  alias CodeTogether.Coderoom

  def start_link do
    GenServer.start_link __MODULE__, %{}
  end

  def init state do
    schedule_work
    {:ok, state}
  end

  def handle_info :work, state do
    Coderoom.close_inactive_rooms
    schedule_work
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after self, :work, 1000 * 60 * 15
  end

end
