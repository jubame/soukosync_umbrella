defmodule Soukosync.Scheduler do
  require Logger
  use GenServer
  alias Soukosync.Caller

  @default_interval_seconds 60

  def get_interval_time do
    Application.get_env(:soukosync, :scheduler_interval_seconds) || @default_interval_seconds
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    Logger.info("Soukosync.Scheduler: GenServer init(), interval: #{get_interval_time()} seconds")
    tick()
    {:ok, state}
  end

  defp tick, do: Process.send_after(self(), :tick, get_interval_time() * 1000)

  def handle_info(:tick, state) do
    Logger.info("Soukosync.Scheduler: Caller.sync_user_warehouses()")
    Caller.sync_cast()
    tick()
    {:noreply, state}
  end



end
