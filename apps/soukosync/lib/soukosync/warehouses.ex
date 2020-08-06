defmodule Soukosync.Warehouses do
  @moduledoc """
  The Warehouses context.
  """

  import Ecto.Query, warn: false
  alias Soukosync.Repo
  alias Soukosync.Helpers

  alias Soukosync.Warehouses.Warehouse
  alias Soukosync.Accounts
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

  def upsert_warehouse(warehouse) do
    data = Accounts.get_user_warehouses()
    '''
    # Filter fields to do this...
    Repo.insert_all(
      Warehouse,
      data
    )
    '''

    IO.inspect(data)
    struct = Enum.map(
      data,
      fn warehouse ->
        Helpers.to_struct_from_string_keyed_map(Warehouse, warehouse)
      end
    )


    IO.inspect(
    Enum.map(
      struct,
      fn warehouse ->
        Repo.insert!(warehouse, on_conflict: :nothing)
      end
    )
    )

  end








end
