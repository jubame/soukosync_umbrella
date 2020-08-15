defmodule Soukosync.TokenStore do

  alias Soukosync.Token

  require Logger
  use GenServer
  alias Soukosync.API
  alias Soukosync.Helpers



  @me TokenStore
  @default_retry_time_seconds 20

  def start_link(current_user) do
    GenServer.start_link(__MODULE__, current_user, name: @me)
  end

  def state() do
    GenServer.call(@me, :state)
  end

  def get_token() do
    GenServer.call(@me, :get_token)
  end

  defp get_retry_time do
    case System.get_env("TOKEN_RETRY_TIME") do
      nil -> @default_retry_time_seconds
      string_seconds -> String.to_integer(string_seconds)
    end
  end

  defp schedule_renew(seconds), do: Process.send_after(self(), :renew, seconds * 1000)

  defp fetch_token do
    fetch_token(System.get_env("API_USER"), System.get_env("API_PASSWORD"))
  end

  defp fetch_token(user, password) when is_nil(user) or is_nil(password) do
    {:error, "Environment variables API_USER or API_PASSWORD not set."}
  end

  defp fetch_token(user, password) do
    case API.get_user_token(user, password) do
      {:ok, token_data} ->
        Logger.info("Soukosync.TokenStore: got token #{token_data}")
        token = %Token{
          Helpers.to_struct_from_string_keyed_map(Token, token_data)
          | valid_from: DateTime.utc_now()}
        schedule_renew(token.expires_in)
        {:ok, token}
      {:error, httpoison_error = %HTTPoison.Error{}} ->
        Logger.error("Soukosync.TokenStore: failed to get token: HTTPoison.Error #{httpoison_error.reason}. Retryig in seconds")
        schedule_renew(get_retry_time())
        {:error, httpoison_error}
      {:error, data} ->
        Logger.error("Soukosync.TokenStore: failed to get token: #{inspect(data)}")
        {:error, data}
    end
  end

  defp init_token do
    init_token(System.get_env("TOKEN"))
  end

  defp init_token(token_env) when is_nil(token_env) do
    case fetch_token() do
      {:ok, token} -> token
      {:error, _reason} ->
        schedule_renew(get_retry_time())
        %Token{}
    end
  end

  defp init_token(token_env) do
    Logger.info("Soukosync.TokenStore: storing manual TOKEN env variable #{token_env}")
    %Token{access_token: token_env}
  end




  def init(_) do
    Logger.info("Soukosync.TokenStore: GenServer init().")
    {:ok, init_token()}
  end

  def handle_call(:state, _from, token ) do
    {
      :reply,
      token,
      token
    }
  end

  def handle_call(:get_token, _from, token ) do
    {result, token} = if Token.is_valid(token) do
      {:ok, token}
    else
      fetch_token()
    end
    {
      :reply,
      {result, token},
      token
    }
  end

  def handle_info(:renew, _old_token) do
    {:noreply, fetch_token()}
  end









end
