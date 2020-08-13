defmodule Soukosync.API do
  use HTTPoison.Base

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
end
