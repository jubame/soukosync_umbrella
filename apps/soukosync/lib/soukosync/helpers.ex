defmodule Soukosync.Helpers do

  def handle_response({:ok, response}) do
    handle_response(response)
  end
  def handle_response({:error, reason}) do
    raise List.to_string(reason)
  end
  def handle_response({{_version, status, _reason}, _headers, body}) do
    handle_response({status, body})
  end
  def handle_response({200, body}) do
    Jason.decode!(body)
  end
  def handle_response({status, body}) do
    reason = [status: status, body: body]
    handle_response({:error, reason})
  end

  # https://stackoverflow.com/a/37734864/12315725
  def to_struct_from_string_keyed_map(kind, attrs) do
    struct = struct(kind)
    Enum.reduce Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end
  end

end
