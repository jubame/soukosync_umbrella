defmodule Soukosync.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Soukosync.Repo
  alias Soukosync.Helpers

  alias Soukosync.Accounts.User
  alias Soukosync.Warehouses.Warehouse

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
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
    |> Helpers.handle_response
    |> change_id_key_name
    Helpers.to_struct_from_string_keyed_map(User, data)
  end

  def upsert_user(user) do
    Repo.insert!(
      user,
      on_conflict: :replace_all_except_primary_key,
      conflict_target: [:origin_id]
    )
  end

  def get_and_upsert_current_user do
    %{get_current_user() | :warehouses => []}
    |> upsert_user()
  end

  defp change_id_key_name(data) do
    Map.put(data, "origin_id", data["id"])
    |> Map.delete("id")
  end



  def get_current_user_warehouses() do
    %User{} = user = get_current_user()
    get_user_warehouses(user)
  end

  def get_user_warehouses(user) do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    token_oauth_api = Application.get_env(:soukosync, :token_oauth_api)

    path = "iam/users/#{user.origin_id}/warehouses"
    final = "#{api_base_url}/#{path}"
    headers = [{'authorization', 'Bearer #{token_oauth_api}'}]
    options = [ssl: [verify: :verify_none]]
    request = {'https://#{final}', headers}

    IO.inspect(final)

    data_warehouses = :httpc.request(:get, request, options, [])
    |> Helpers.handle_response
    |> Map.get("warehouses")
    |> Enum.map(
      fn data_warehouse ->
        change_id_key_name(data_warehouse)
      end
    )

    user_warehouses_origin_ids = Enum.map(
      data_warehouses,
      fn data_warehouse -> data_warehouse["origin_id"] end
    )

    warehouses_already_db =  from(warehouse in Warehouse, where: warehouse.id in ^user_warehouses_origin_ids) |> Repo.all
    warehouses_already_db_ids = Enum.map(
      warehouses_already_db,
      fn warehouse ->
        warehouse.origin_id
      end
    )
    warehouses_not_db_ids = Enum.filter(
      user_warehouses_origin_ids,
      fn el -> !Enum.member?(warehouses_already_db_ids, el) end
    )
    IO.inspect(warehouses_not_db_ids)

    data_warehouses_not_db = Enum.filter(
      data_warehouses,
      fn data_warehouse ->
        IO.inspect(data_warehouse["origin_id"])
        Enum.member?(warehouses_not_db_ids, data_warehouse["origin_id"])
      end
    )
    IO.puts("=========================================================== data_warehouses_not_db")



    IO.inspect(data_warehouses_not_db)


    IO.puts("=========================================================== data_warehouses_not_db_struct")

    IO.inspect(
    Enum.map(
      data_warehouses_not_db,
      fn data_warehouse_not_db ->

        %{
          Helpers.to_struct_from_string_keyed_map(
            Warehouse,
            data_warehouse_not_db
          )
          | users: [user] }
      end
    )
    )



    Enum.map(
      warehouses_already_db,
      fn warehouse ->
        Map.replace!(warehouse, :users, [user | warehouse.users])
      end
    )





    # data_warehouses_mod = Enum.map(
    #   data_warehouses,
    #   fn data_warehouse ->
    #     change_id_key_name(data_warehouse)
    #   end
    # )
    # Enum.map(
    #   data_warehouses_mod,
    #   fn data_warehouse_mod ->
    #     %{ Helpers.to_struct_from_string_keyed_map(Warehouse, data_warehouse_mod) | users: [user] }
    #   end
    # )




  end










end
