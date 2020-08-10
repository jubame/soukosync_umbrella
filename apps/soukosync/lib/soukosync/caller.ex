defmodule Soukosync.Caller do
  require Logger
  use GenServer
  alias Soukosync.Accounts


  @me Caller

  def start_link(current_user) do
    GenServer.start_link(__MODULE__, current_user, name: @me)
  end

  def sync_user_warehouses() do
    GenServer.cast(@me, :sync_user_warehouses)
  end

  def init(_) do

    Logger.info("Soukosync.Caller: GenServer init()")
    if Mix.env == :test do
      { :ok, 0 }
    else
      { :ok, 0 }
    end
  end

  def handle_cast(:sync_user_warehouses, current_user) do
    Logger.info("Soukosync.Caller: calling Soukosync.Sync.upsert_user_warehouses()")
    IO.puts(":sync_user_warehouses #{current_user.email}")
    { :noreply, current_user }
  end


end
