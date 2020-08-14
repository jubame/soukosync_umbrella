# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

# Only works for compile time. Setting url in Soukosync.Repo init()
# allows reading it from environment variable during runtime. See:
# https://hexdocs.pm/ecto/Ecto.Repo.html#module-urls
# > In case the URL needs to be dynamically configured, for example by reading
# > a system environment variable, such can be done via the init/2 repository
# > callback
#
# database_url =
#   System.get_env("DATABASE_URL") ||
#     raise """
#     environment variable DATABASE_URL is missing.
#     For example: ecto://USER:PASS@HOST/DATABASE
#     """

config :soukosync, Soukosync.Repo,
  # ssl: true,
  # url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :soukosync_web, SoukosyncWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :soukosync_web, SoukosyncWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
