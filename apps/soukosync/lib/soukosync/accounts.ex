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

  def get_current_user_id() do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    token_oauth_api = Application.get_env(:soukosync, :token_oauth_api)
    path = "iam/users/me"
    final = "#{api_base_url}/#{path}"

    headers = [{'authorization', 'Bearer #{token_oauth_api}'}]
    options = [ssl: [verify: :verify_none]]
    request = {'https://#{final}', headers}

    data = :httpc.request(:get, request, options, [])
    |> Helpers.handle_response

    data["id"]

  end



  def upsert_user(user) do
    Repo.insert!(
      user,
      on_conflict: :replace_all_except_primary_key,
      conflict_target: [:origin_id]
    )
  end


  def get_user_warehouses() do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    token_oauth_api = Application.get_env(:soukosync, :token_oauth_api)

    user_id = get_current_user_id

    path = "iam/users/#{user_id}/warehouses"
    final = "#{api_base_url}/#{path}"
    headers = [{'authorization', 'Bearer #{token_oauth_api}'}]
    options = [ssl: [verify: :verify_none]]
    request = {'https://#{final}', headers}

    IO.inspect(final)

    data_user_warehouses = :httpc.request(:get, request, options, [])
    |> Helpers.handle_response

    data_user = Map.delete(data_user_warehouses, "warehouses")
    data_warehouses = Map.get(data_user_warehouses, "warehouses")

    warehouses_struct = Enum.map(
      data_warehouses,
      fn data_warehouse ->
        Helpers.to_struct_from_string_keyed_map(Warehouse, data_warehouse)
      end
    )

    user_struct = Helpers.to_struct_from_string_keyed_map(User, data_user)
    user_warehouses_struct = user_struct
    |> Map.put(:warehouses, warehouses_struct)

    IO.inspect(data_user)


    user = Repo.get(User, user_id) || User.changeset(%User{id: user_id}, data_user)
    |> Repo.insert!(on_conflict: :nothing)

    IO.puts("aqui")

    IO.inspect(
    Enum.map(
      warehouses_struct,
      fn warehouse ->
        case Repo.get(Warehouse, warehouse.id) do
          nil ->
            warehouse = Map.put(warehouse, :users, [user])
            Repo.insert!(warehouse)
          existing ->
            existing_preload = existing |> Repo.preload(:users)
            changeset = Warehouse.changeset(existing_preload, Map.from_struct(warehouse))
            existing_users_ids = Enum.map(
              existing_preload.users,
              fn existing_user ->
                existing_user.id
              end
            )

            IO.puts(">>>>>>>>>>>>>>>>>>>>>>existing_users")
            IO.inspect(existing_users_ids)
            IO.puts("<<<<<<<<<<<<<<<<<<<<<<existing_users")
            IO.puts(">>>>>>>>>>>>>>>>>>>>>>user")
            IO.inspect(user.id)
            IO.puts(">>>>>>>>>>>>>>>>>>>>>>user")



            if !Enum.member?(existing_users_ids, user.id) do
              IO.puts("member")
              IO.inspect(
              changeset
                |> Ecto.Changeset.put_assoc(:users, [user])
            )

                changeset =
                Ecto.Changeset.put_assoc(changeset, :users, [user])

            end

            Repo.update!(changeset)

        end

      end
    )
    )








      '''
    User.changeset(user, data_user)
        |> Ecto.Changeset.put_assoc(
          :warehouses,
          warehouses_struct
        )
        |> Repo.update!(on_conflict: :nothing)
        '''





  end





  defp change_id_key_name(data) do
    Map.put(data, "origin_id", data["id"])
    |> Map.delete("id")
  end







end
