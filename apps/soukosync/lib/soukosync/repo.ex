defmodule Soukosync.Repo do
  use Ecto.Repo,
    otp_app: :soukosync,
    adapter: Ecto.Adapters.Postgres
end
