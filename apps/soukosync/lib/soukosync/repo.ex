defmodule Soukosync.Repo do
  use Ecto.Repo,
    otp_app: :soukosync,
    adapter: Ecto.Adapters.Postgres,
    show_sensitive_data_on_connection_error: true


    @doc """
    Dynamically loads the repository url from the
    DATABASE_URL environment variable.
    """
    def init(_, config) do
      config = config
      |> Keyword.put(:show_sensitive_data_on_connection_error, true)
      |> Keyword.put(:url, System.get_env("DATABASE_URL"))
      {:ok, config}
    end

end
