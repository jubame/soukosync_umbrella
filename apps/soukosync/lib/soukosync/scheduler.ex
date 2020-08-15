defmodule Soukosync.Scheduler do
  require Logger
  use GenServer
  alias Soukosync.Caller

  @default_interval_seconds 60

  def get_interval_time do
    case System.get_env("INTERVAL_SCHEDULER_SECONDS") do
      nil -> @default_interval_seconds
      "" -> @default_interval_seconds
      interval -> String.to_integer(interval)
    end
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
    Logger.info("Soukosync.Scheduler -> Caller.sync_cast()")
    if Application.get_env(:soukosync, :environment) == :test do
      Logger.warn("Scheduler periodic Caller.sync_cast() execution disabled in test environment to avoid writing to DB while tests are running.")
    else
      Caller.sync_cast()
    end
    tick()
    {:noreply, state}
  end



end
