defmodule Soukosync.Scheduler do
  require Logger
  use GenServer
  alias Soukosync.Caller

  @tick_interval 1000_000

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    Logger.info("Soukosync.Scheduler: GenServer init(), tick interval: #{@tick_interval}")
    tick()
    {:ok, state}
  end

  defp tick, do: Process.send_after(self(), :tick, @tick_interval)

  def handle_info(:tick, state) do
    Logger.info("Soukosync.Scheduler: Caller.sync_user_warehouses()")
    Caller.sync_user_warehouses()
    tick()
    {:noreply, state}
  end



end
