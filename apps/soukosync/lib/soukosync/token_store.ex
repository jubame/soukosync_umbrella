defmodule Soukosync.TokenStore do

  alias Soukosync.Token

  require Logger
  use GenServer
  alias Soukosync.API
  alias Soukosync.Helpers
  alias Soukosync.Caller



  @me TokenStore
  @default_retry_time_seconds 10

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
    Application.get_env(:soukosync, :token_store_retry_time_seconds) || @default_retry_time_seconds
  end

  defp schedule_renew(seconds), do: Process.send_after(self(), :renew, seconds * 1000)

  defp fetch_token do
    fetch_token(System.get_env("API_USER"), System.get_env("API_PASSWORD"))
  end

  defp fetch_token(user, password) when is_nil(user) or is_nil(password) do
    {:error, "Environment variables API_USER or API_PASSWORD not set. Please exit and restart."}
  end

  defp fetch_token(user, password) do
    case API.get_user_token(user, password) do
      {:ok, token_data} ->
        token_struct = Helpers.to_struct_from_string_keyed_map(Token, token_data)
        Logger.info("Soukosync.TokenStore: got token #{token_struct.access_token}")
        token = %Token{
          token_struct
          | valid_from: DateTime.utc_now()}
        #schedule_renew(token.expires_in)
        {:ok, token}
      {:error, httpoison_error = %HTTPoison.Error{}} ->
        Logger.error("Soukosync.TokenStore: failed to get token: HTTPoison.Error #{httpoison_error.reason}. Retrying in #{get_retry_time()} seconds")
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
        nil
    end
  end

  defp init_token(token_env) do
    Logger.info("Soukosync.TokenStore: storing manual TOKEN env variable #{token_env}")
    %Token{access_token: token_env, expires_in: 0}
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
      case fetch_token() do
        {:ok, token} -> {:ok, token}
        {:error, _data} -> {:error, nil}
      end
    end

    {
      :reply,
      {result, token},
      token
    }
  end


  def handle_info(:renew, old_token) do
    # Check old_token validity
    # Mainly to guard against no internet connection at startup, as
    # both TokenStore and Caller will request tokens (the latter through
    # get_current_user) at barely the same time and both will fail. Therefore,
    # fetch_token will generate two renews, one of which will be unnecessary
    # as it will be already stored at TokenStore (here old_token parameter).
    if Token.is_valid(old_token) do
      {:noreply, old_token}
    else
      case fetch_token() do
        {:ok, token} ->
          # https://medium.com/appunite-edu-collection/quick-look-at-new-gen-server-handle-continue-callback-2ef0408391ff
          {:noreply, token, {:continue, :caller_check_user}}
        {:error, data} ->
          Logger.info "TokenStore :renew: error #{inspect(data)}"
          {:noreply, nil}
      end
    end
  end

  def handle_continue(:caller_check_user, token) do
    Logger.info "TokenStore handle_continue :caller_check_user #{DateTime.utc_now()}"
    Caller.check_user()
    {:noreply, token}
  end










end
