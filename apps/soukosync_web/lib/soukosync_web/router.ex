defmodule SoukosyncWeb.Router do
  use SoukosyncWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SoukosyncWeb do
    pipe_through :api
    resources "/users", UserController, except: [:new, :edit]
    resources "/warehouses", WarehouseController, except: [:new, :edit]
    patch "/syncall", SyncController, :sync_call
    patch "/syncast", SyncController, :sync_cast
  end
end
