defmodule Soukosync.TokenStore do

  alias Soukosync.Token

  require Logger
  use GenServer
  alias Soukosync.API
  alias Soukosync.Helpers



  @me TokenStore

  def start_link(current_user) do
    GenServer.start_link(__MODULE__, current_user, name: @me)
  end

  def state() do
    GenServer.call(@me, :state)
  end

  def get_token() do
    GenServer.call(@me, :get_token)
  end

  defp schedule_renew(seconds), do: Process.send_after(self(), :renew, seconds * 1000)

  def init(_) do
    IO.puts("HOLA")
    token_env = System.get_env("TOKEN")
    IO.inspect(token_env)
    {:ok, init_fetch_token(token_env)}
  end

  defp init_fetch_token(token_env) when is_nil(token_env) do
    case fetch_token() do
      {:ok, token} -> token
      {:error, _reason} ->
        schedule_renew(3600)
        %Token{}
    end
  end

  defp init_fetch_token(token_env) do
    %Token{access_token: token_env}
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



  defp fetch_token do
    fetch_token(System.get_env("API_USER"), System.get_env("API_PASSWORD"))
  end

  defp fetch_token(user, password) when is_nil(user) or is_nil(password) do
    {:error, "Environment variables API_USER or API_PASSWORD not set"}
  end

  defp fetch_token(user, password) do
    with {:ok, token_data} <- API.get_user_token(user, password) do
      token = %Token{
        Helpers.to_struct_from_string_keyed_map(Token, token_data)
        | valid_from: DateTime.utc_now()}
      schedule_renew(token.expires_in)
      {:ok, token}
    end
  end





end
