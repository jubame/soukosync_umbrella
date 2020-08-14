defmodule Soukosync.API do
  use HTTPoison.Base
  require Logger
  alias Soukosync.Helpers

  def get_user_token(username, password) do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    path = "auth"
    url = "https://#{api_base_url}/#{path}"

    headers = ["Content-Type": "application/json"]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    body_map = %{
      "grant_type": "password",
      "username": username,
      "password": password,
      "scope": "default"
    }

    with {:ok, body_json} = Poison.encode(body_map),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.post(url, body_json, headers),
         {:ok, data_token} <- Poison.decode(body)
    do
      {:ok, data_token}
    end
  end



  def get_current_user() do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    token_oauth_api = System.get_env("TOKEN")
    path = "iam/users/me"
    url = "https://#{api_base_url}/#{path}"

    headers = ["Authorization": "Bearer #{token_oauth_api}"]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    Logger.info("Soukosync.API: Querying #{url}")
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- Helpers.check_unauthorized(HTTPoison.get(url, headers, options)),
         {:ok, data_user} <- Poison.decode(body)
    do
      Logger.info("HTTP 200")
      {:ok, data_user}
    end
  end


end
