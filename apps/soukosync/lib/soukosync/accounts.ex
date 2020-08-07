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


    user_warehouses = :httpc.request(:get, request, options, [])
    |> Helpers.handle_response

    #user_warehouses = change_id_key_name(user_warehouses)
    IO.inspect(user_warehouses)

    '''

    data_warehouses = user_warehouses
    |> Map.get("warehouses")
    |> Enum.map(
      fn data_warehouse ->
        Helpers.to_struct_from_string_keyed_map(Warehouse, change_id_key_name(data_warehouse))
      end
    )

    #IO.inspect(data_warehouses)

    user_warehouses = Map.put(
      user_warehouses,
      "warehouses",
      data_warehouses
    )

    '''


    data_warehouses = user_warehouses
    |> Map.get("warehouses")
    IO.puts("****************************************************")
    #IO.inspect(data_warehouses)

    #IO.inspect(user_warehouses)
    #IO.inspect(User.changeset(%User{}, user_warehouses))

    #user_warehouses = Map.delete(user_warehouses, "warehouses")

    #IO.inspect(user_warehouses)


    #Repo.get_by(User, origin_id: user_warehouses["origin_id"])

    #IO.inspect(data_warehouses)

    #user_warehouses_changeset = User.changeset(%User{}, user_warehouses)
    #|> Ecto.Changeset.put_assoc(:warehouses, data_warehouses)


    case Repo.get_by(User, id: user_id) do
      nil ->
        IO.puts("***************************************************NIL")
        User.changeset(%User{}, user_warehouses)
        |> Repo.insert!
      user ->

        IO.puts("***************************************************NOT NIL")
        #IO.inspect(User.changeset(user, user_warehouses) )
        #IO.inspect(user  |> Repo.preload(:warehouses) |> Ecto.Changeset.cast(user_warehouses, []))
        #p = user
        #|> Repo.preload(:warehouses)
        #|> Ecto.Changeset.cast(user_warehouses, [])
        #|> Ecto.Changeset.cast_assoc(:warehouses, required: true, with: &Warehouse.changeset/2 )
        #IO.inspect(p)
        #p
        changeset = user
        |> User.changeset(user_warehouses)
        IO.inspect(changeset)
        changeset
        |> Repo.insert()
        |> case do
          {:ok, user} -> user
          {:error, _} -> IO.puts "nothing"
        end
    end



    #IO.inspect(user_warehouses_changeset)
    #user = Helpers.to_struct_from_string_keyed_map(User, user_warehouses)
    #IO.inspect(user)
    #Repo.insert!(
    #  user_warehouses_changeset, on_conflict: :nothing
    #)


    #Repo.get_by(User, origin_id: user_origin_id)
    #|> Repo.preload(:warehouses)







  end





  defp change_id_key_name(data) do
    Map.put(data, "origin_id", data["id"])
    |> Map.delete("id")
  end







end
