defmodule Soukosync.Caller do
  use GenServer

  @me Caller

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: @me)
  end

  def sync_user_warehouses() do
    GenServer.cast(@me, :sync_user_warehouses)
  end

  def init(state) do
    { :ok, state }
  end

  def handle_cast(:sync_user_warehouses, state) do
    IO.puts(":sync_user_warehouses")
    { :noreply, state }
  end


end
