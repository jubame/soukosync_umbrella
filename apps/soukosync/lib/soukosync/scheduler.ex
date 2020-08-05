defmodule Soukosync.Scheduler do
  use GenServer
  alias Soukosync.Caller

  @tick_interval 1000_000

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    tick()
    {:ok, state}
  end

  defp tick, do: Process.send_after(self(), :tick, @tick_interval)

  def handle_info(:tick, state) do
    IO.puts("tick")
    Caller.sync_user_warehouses()
    tick()
    {:noreply, state}
  end



end
