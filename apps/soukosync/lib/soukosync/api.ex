defmodule Soukosync.API do
  use HTTPoison.Base
  require Logger
  alias Soukosync.Helpers
  alias Soukosync.Token
  alias Soukosync.TokenStore

  def get_user_token(username, password) do

    body_map = %{
      grant_type: "password",
      username: username,
      password: password,
      scope: "default"
    }

    http_post("auth", body_map)
  end

  def http_post(path, body_map) do

    headers = ["Content-Type": "application/json"]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    with {:ok, body_json} = Poison.encode(body_map),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.post(
                                                                       build_api_url(path),
                                                                       body_json,
                                                                       headers,
                                                                       options
                                                                     ),
         {:ok, data} <- Poison.decode(body)
    do
      {:ok, data}
    end

  end



  def http_auth_get_decode(path) do

    headers = []
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    with {:ok, token} <- TokenStore.get_token(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- Helpers.check_unauthorized(
                                                                       HTTPoison.get(
                                                                         build_api_url(path),
                                                                         auth_header(headers, token),
                                                                         options)
                                                                     ),
         {:ok, data} <- Poison.decode(body)
    do
      {:ok, data}
    end
  end

  def build_api_url(path) do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    "https://#{api_base_url}/#{path}"
  end


  def auth_header(headers_so_far, token) do
    [{"Authorization", "Bearer #{token.access_token}"} | headers_so_far]
  end


  def get_current_user() do
    http_auth_get_decode("iam/users/me")
  end


  def get_user_warehouses(user_id) do
    http_auth_get_decode("iam/users/#{user_id}/warehouses")
  end






end
