defmodule Soukosync.Caller do
  require Logger
  use GenServer
  alias Soukosync.Accounts
  import Qex


  @me Caller

  def start_link(current_user) do
    GenServer.start_link(__MODULE__, current_user, name: @me)
  end

  def last_syncs(count) do
    GenServer.call(@me, {:last_syncs,  count})
  end

  def sync_call() do
    GenServer.call(@me, :sync)
  end

  def sync_cast() do
    GenServer.cast(@me, :sync)
  end

  def check_user() do
    GenServer.cast(@me, :check_user)
  end

  def init(_) do
    Logger.info("Soukosync.Caller: GenServer init().")
    current_user = get_current_user()
    {
      :ok,
      { current_user, Qex.new }
    }
  end

  defp get_current_user() do
    case Soukosync.Accounts.get_current_user() do
      {:ok, current_user } ->
        Logger.info("Soukosync.Caller.get_current_user: stored user #{current_user.username}, id: #{current_user.id} in GenServer state.")
        current_user
      {:error, httpoison_error = %HTTPoison.Error{}} ->
        Logger.error("error Soukosync.Caller.get_current_user: HTTPoison.Error #{httpoison_error.reason}")
        nil
      {:error, reason} ->
        Logger.error("error Soukosync.Caller.get_current_user: #{reason}")
        nil
    end
  end

  def handle_call({:last_syncs, count}, _from, { current_user, last_syncs } ) do

    IO.inspect(count)

    {_q1, q2} = Qex.split(last_syncs, max(0, Enum.count(last_syncs) - count))
    {
      :reply,
      q2,
      { current_user,  last_syncs }
    }
  end

  def handle_cast(:check_user, { current_user, last_syncs } ) when current_user == nil do
    current_user = get_current_user()
    {
      :noreply,
      { current_user,  last_syncs }
    }
  end

  def handle_cast(:check_user, { current_user, last_syncs } ) do
    {
      :noreply,
      { current_user,  last_syncs }
    }
  end

  def handle_call(:sync, _from, { current_user, last_syncs } ) do
    last_syncs = sync_and_push_queue( { current_user, last_syncs } )
    last_sync = case last(last_syncs) do
      :empty -> nil
      {:value, last_sync} -> last_sync
    end

    {
      :reply,
      last_sync,
      { current_user,  last_syncs }
    }
  end

  def handle_cast(:sync, { current_user, last_syncs } ) do
    last_syncs = sync_and_push_queue( { current_user, last_syncs } )
    {
      :noreply,
      { current_user,  last_syncs }
    }
  end

  defp sync_and_push_queue({ current_user, last_syncs }) when current_user == nil do
    Logger.warn "Soukosync.Caller: sync_and_push_queue: current_user is nil. Trying to get it again..."
    case get_current_user() do
      nil ->
        Logger.warn "   Soukosync.Caller: sync_and_push_queue: still nil. Doing nothing."
        last_syncs
      fetched_user ->
        Logger.info "   Soukosync.Caller: sync_and_push_queue: got user #{fetched_user.username}"
        sync_and_push_queue({ fetched_user, last_syncs })
    end
  end

  defp sync_and_push_queue({ current_user, last_syncs }) do
    Logger.info("Soukosync.Caller: calling Soukosync.Sync.upsert_user_warehouses()")
    now = DateTime.utc_now()
    to_store = case Soukosync.Sync.upsert_user_warehouses(current_user.id) do
      {:ok, structs} -> {:ok, now, "全部ＯＫ、#{Enum.count(structs)}つ　入れちゃった！"}
      {:error, value} -> {:error, now, value}
    end
    last_syncs = push_limit(
      last_syncs,
      to_store
    )
    IO.inspect(last_syncs)
    last_syncs
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
