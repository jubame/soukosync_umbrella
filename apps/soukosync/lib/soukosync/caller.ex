defmodule Soukosync.Caller do
  require Logger
  use GenServer
  import Qex


  @me Caller

  def start_link(current_user) do
    GenServer.start_link(__MODULE__, current_user, name: @me)
  end

  def last_syncs(count) do
    GenServer.call(@me, {:last_syncs,  count})
  end

  def last_syncs() do
    GenServer.call(@me, :last_syncs)
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
    {
      :ok,
      { nil, Qex.new }
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
        Logger.error("error Soukosync.Caller.get_current_user: #{inspect(reason)}")
        nil
    end
  end

  def handle_call({:last_syncs, count}, _from, { current_user, last_syncs } ) do
    {_q1, q2} = Qex.split(last_syncs, max(0, Enum.count(last_syncs) - count))
    {
      :reply,
      q2,
      { current_user,  last_syncs }
    }
  end

  def handle_call(:last_syncs, _from, { current_user, last_syncs } ) do
    {
      :reply,
      last_syncs,
      { current_user,  last_syncs }
    }
  end

  def handle_call(:sync, _from, { current_user, last_syncs } ) when current_user == nil do
    Logger.warn "Soukosync.Caller: :sync current_user is nil. Doing nothing. If using API_TOKEN auth, please ensure it is valid or unset it and set API_USER and API_PASSWORD"
    {
      :reply,
      {:error, "current user is nil"},
      { current_user,  last_syncs }
    }
  end

  def handle_call(:sync, _from, { current_user, last_syncs } ) do
    last_syncs = sync_and_push_queue( { current_user, last_syncs } )
    {
      :reply,
      last(last_syncs),
      { current_user,  last_syncs }
    }
  end

  def handle_cast(:sync, { current_user, last_syncs } ) when current_user == nil do
    Logger.warn "Soukosync.Caller: :sync current_user is nil. Doing nothing. If using API_TOKEN auth, please ensure it is valid or unset it and set API_USER and API_PASSWORD"
    {
      :noreply,
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

  def handle_cast(:check_user, { current_user, last_syncs } ) when current_user == nil do
    Logger.warn "Soukosync.Caller: :check_user current_user is nil"
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

  defp sync_and_push_queue({ current_user, last_syncs }) when current_user == nil do
    Logger.warn "Soukosync.Caller: sync_and_push_queue: current_user is nil. Outta here..."
    last_syncs
  end

  defp sync_and_push_queue({ current_user, last_syncs }) do
    Logger.info("Soukosync.Caller: calling Soukosync.Sync.upsert_user_warehouses()")
    now = DateTime.utc_now()
    to_store = case Soukosync.Sync.upsert_user_warehouses(current_user.id) do

      {:ok, structs} ->
        # 全部ＯＫ、全部 入れちゃった！
        {:ok, now, "#{Enum.count(structs)} upserted"}
      {:error, value} ->
        # だめだ
        {:error, now, value}
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
