defmodule SoukosyncWeb.SyncController do
  use SoukosyncWeb, :controller

  alias Soukosync.Accounts
  alias Soukosync.Accounts.User

  action_fallback SoukosyncWeb.FallbackController

  def sync_last(conn, %{"count" => count}) do
    last_syncs = Soukosync.Caller.last_syncs(String.to_integer(count))
    render(conn, "index.json", %{last_syncs: last_syncs})
  end

  def sync_call(conn, _params) do
    IO.puts("HOLA")
    #users = Accounts.list_users()
    #render(conn, "index.json", users: users)
    last_sync = Soukosync.Caller.sync_call()

    IO.inspect(last_sync)
    render(
      conn,
      "sync.json",
      %{sync: last_sync}
    )
  end

  def sync_cast(conn, _params) do
    IO.puts("HOLA")
    #users = Accounts.list_users()
    #render(conn, "index.json", users: users)
    :ok = Soukosync.Caller.sync_cast()
    render(
      conn,
      "sync.json",
      %{sync: {:ok, DateTime.utc_now(), "Soukosync.Caller.cast_sync casted"}}
    )
  end

end
