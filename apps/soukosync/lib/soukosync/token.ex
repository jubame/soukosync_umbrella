defmodule Soukosync.Token do
  defstruct [
    :access_token,
    :valid_from,
    :expires_in,
    scope: "default",
    token_type: "bearer"
  ]

  def is_valid(token) when token == nil do
    false
  end
  def is_valid(token) do
    token.expires_in == :never || DateTime.diff(token.valid_from, DateTime.utc_now(), :second) > token.expires_in
  end

end
