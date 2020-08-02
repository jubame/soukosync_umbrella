defmodule SoukosyncWeb.Router do
  use SoukosyncWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SoukosyncWeb do
    pipe_through :api
  end
end
