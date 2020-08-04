defmodule Soukosync.Sync do
  @moduledoc """
  The Sync context.
  """

  import Ecto.Query, warn: false
  alias Soukosync.Repo

  alias Soukosync.Sync.Warehouse
  alias Soukosync.Accounts.User

  @doc """
  Returns the list of warehouses.

  ## Examples

      iex> list_warehouses()
      [%Warehouse{}, ...]

  """
  def list_warehouses do
    Repo.all(Warehouse)
  end

  @doc """
  Gets a single warehouse.

  Raises `Ecto.NoResultsError` if the Warehouse does not exist.

  ## Examples

      iex> get_warehouse!(123)
      %Warehouse{}

      iex> get_warehouse!(456)
      ** (Ecto.NoResultsError)

  """
  def get_warehouse!(id), do: Repo.get!(Warehouse, id)

  @doc """
  Creates a warehouse.

  ## Examples

      iex> create_warehouse(%{field: value})
      {:ok, %Warehouse{}}

      iex> create_warehouse(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_warehouse(attrs \\ %{}) do
    %Warehouse{}
    |> Warehouse.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a warehouse.

  ## Examples

      iex> update_warehouse(warehouse, %{field: new_value})
      {:ok, %Warehouse{}}

      iex> update_warehouse(warehouse, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_warehouse(%Warehouse{} = warehouse, attrs) do
    warehouse
    |> Warehouse.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a warehouse.

  ## Examples

      iex> delete_warehouse(warehouse)
      {:ok, %Warehouse{}}

      iex> delete_warehouse(warehouse)
      {:error, %Ecto.Changeset{}}

  """
  def delete_warehouse(%Warehouse{} = warehouse) do
    Repo.delete(warehouse)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking warehouse changes.

  ## Examples

      iex> change_warehouse(warehouse)
      %Ecto.Changeset{source: %Warehouse{}}

  """
  def change_warehouse(%Warehouse{} = warehouse) do
    Warehouse.changeset(warehouse, %{})
  end

  def get_current_user() do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    token_oauth_api = Application.get_env(:soukosync, :token_oauth_api)
    path = "iam/users/me"
    final = "#{api_base_url}/#{path}"

    headers = [{'authorization', 'Bearer #{token_oauth_api}'}]
    options = [ssl: [verify: :verify_none]]
    request = {'https://#{final}', headers}

    data = :httpc.request(:get, request, options, [])
    |> handle_response
    to_struct_from_string_keyed_map(User, data)
  end

  def get_current_user_warehouses() do
    %User{} = user = get_current_user()
    get_user_warehouses(user.id)
  end

  def get_user_warehouses(user_id) do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    token_oauth_api = Application.get_env(:soukosync, :token_oauth_api)

    path = "iam/users/#{user_id}/warehouses"
    final = "#{api_base_url}/#{path}"
    headers = [{'authorization', 'Bearer #{token_oauth_api}'}]
    options = [ssl: [verify: :verify_none]]
    request = {'https://#{final}', headers}

    IO.inspect(final)

    :httpc.request(:get, request, options, [])
    |> handle_response
    |> Map.get("warehouses")
  end


  defp handle_response({:ok, response}) do
    handle_response(response)
  end
  defp handle_response({:error, reason}) do
    raise List.to_string(reason)
  end
  defp handle_response({{_version, status, _reason}, _headers, body}) do
    handle_response({status, body})
  end
  defp handle_response({200, body}) do
    Jason.decode!(body)
  end
  defp handle_response({status, body}) do
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
