defmodule SoukosyncWeb.SyncController do
  use SoukosyncWeb, :controller

  alias Soukosync.Accounts
  alias Soukosync.Accounts.User

  action_fallback SoukosyncWeb.FallbackController

  def sync(conn, _params) do
    IO.puts("HOLA")
    #users = Accounts.list_users()
    #render(conn, "index.json", users: users)
    :ok = Soukosync.Caller.sync_user_warehouses()
    render(conn, "sync.json", %{message: "Soukosync.Caller.sync_user_warehouses called"})
  end

end
