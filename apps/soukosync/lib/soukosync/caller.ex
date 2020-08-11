defmodule Soukosync.Caller do
  require Logger
  use GenServer
  alias Soukosync.Accounts
  import Qex


  @me Caller

  def start_link(current_user) do
    GenServer.start_link(__MODULE__, current_user, name: @me)
  end

  def sync_user_warehouses() do
    GenServer.cast(@me, :sync_user_warehouses)
  end

  def init(_) do
    Logger.info("Soukosync.Caller: GenServer init().")
    {:ok, current_user } = Soukosync.Accounts.get_current_user()
    Logger.info("Soukosync.Caller: stored user #{current_user.username}, id: #{current_user.id} in GenServer state.")
    if Mix.env == :test do
      { :ok, current_user }
    else
      {
        :ok,
        { current_user, Qex.new }
      }
    end
  end

  def handle_cast(:sync_user_warehouses, { current_user, last_syncs } ) do
    Logger.info("Soukosync.Caller: calling Soukosync.Sync.upsert_user_warehouses()")
    Soukosync.Sync.upsert_user_warehouses(current_user.id)
    last_syncs = push_limit(last_syncs, DateTime.utc_now())
    IO.inspect(last_syncs)
    {
      :noreply,
      { current_user,  last_syncs }
    }
  end

  defp push_limit(last_syncs, value) do
    last_syncs = if Enum.count(last_syncs) >= 100 do
      {{:value, _popped_item}, last_syncs} = Qex.pop(last_syncs)
      last_syncs
    else
      last_syncs
    end
    Qex.push(last_syncs, value)
  end



end
