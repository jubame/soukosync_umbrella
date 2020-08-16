use Mix.Config

config :soukosync,
  environment: :test

# Configure your database
config :soukosync, Soukosync.Repo,
  username: "postgres",
  password: "postgres",
  database: "soukosync_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :soukosync_web, SoukosyncWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger,
  backends: [:console],
  compile_time_purge_level: :debug
