# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config


# Configure Mix tasks and generators
config :soukosync,
  ecto_repos: [Soukosync.Repo],
  api_base_url: "show.pulpo.co/api/v1",
  token_store_retry_time_seconds: 10,
  scheduler_interval_seconds: 60



config :soukosync_web,
  ecto_repos: [Soukosync.Repo],
  generators: [context_app: :soukosync]

# Configures the endpoint
config :soukosync_web, SoukosyncWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uwYKTA/ru01dokXIMOjDbqBmQ0Kh3VcDgIsvuvAaNJReDuRLygUNU9GuouNUqT7s",
  render_errors: [view: SoukosyncWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: SoukosyncWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
