defmodule Soukosync.API do
  use HTTPoison.Base
  require Logger
  alias Soukosync.Helpers
  alias Soukosync.Token
  alias Soukosync.TokenStore

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
    path = "iam/users/me"
    url = "https://#{api_base_url}/#{path}"

    headers = []
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    Logger.info("Soukosync.API: Querying #{url}")
    with {:ok, token} <- TokenStore.get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- Helpers.check_unauthorized(
                                                                       HTTPoison.get(
                                                                         url,
                                                                         auth_header(headers, token),
                                                                         options)
                                                                     ),
         {:ok, data_user} <- Poison.decode(body)
    do
      Logger.info("HTTP 200")
      {:ok, data_user}
    end
  end

  def auth_header(headers_so_far, token) do
    [{"Authorization", "Bearer #{token.access_token}"} | headers_so_far]
  end


  def get_user_warehouses(user_id) do
    headers = []
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    with {:ok, token} <- TokenStore.get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- Helpers.check_unauthorized(
                                                                       HTTPoison.get(
                                                                         build_user_warehouses_url(user_id),
                                                                         auth_header(headers, token),
                                                                         options)
                                                                     ),
         {:ok, data_user_warehouses} <- Poison.decode(body)
    do
      Logger.info("HTTP 200")
      {:ok, data_user_warehouses}
    end
  end

  defp build_user_warehouses_url(user_id) do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    path = "iam/users/#{user_id}/warehouses"
    url = "https://#{api_base_url}/#{path}"
    Logger.info("Soukosync.Sync: Querying #{url}")
    url
  end


end
