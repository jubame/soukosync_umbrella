defmodule Soukosync.Caller do
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
    if Mix.env == :test do
      { :ok, Accounts.get_current_user }
    else
      { :ok, Accounts.get_and_upsert_current_user }
    end
  end

  def handle_cast(:sync_user_warehouses, current_user) do
    IO.puts(":sync_user_warehouses #{current_user.email}")
    { :noreply, current_user }
  end


end
