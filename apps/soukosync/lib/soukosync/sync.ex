defmodule Soukosync.Sync do
  @moduledoc """
  The Sync context.
  """
  require Logger
  import Ecto.Query, warn: false
  alias Soukosync.Repo
  alias Soukosync.Helpers
  alias Soukosync.Accounts.User
  alias Soukosync.Warehouses.Warehouse

  def upsert_user_warehouses() do
    {:ok, %User{id: user_id}} = Soukosync.Accounts.get_current_user()
    upsert_user_warehouses(user_id)
  end

  def upsert_user_warehouses(user_id) do
    token_oauth_api = Application.get_env(:soukosync, :token_oauth_api)
    headers = ["Authorization": "Bearer #{token_oauth_api}"]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- Helpers.check_unauthorized(HTTPoison.get(build_user_warehouses_url(user_id), headers, options)),
         {:ok, data_user_warehouses} <- Poison.decode(body)
    do
      upsert_user_warehouses(user_id, data_user_warehouses)
    end
  end

  defp build_user_warehouses_url(user_id) do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    path = "iam/users/#{user_id}/warehouses"
    url = "https://#{api_base_url}/#{path}"
    Logger.info("Soukosync.Sync: Querying #{url}")
    url
  end


  def upsert_user_warehouses(user_id, data_user_warehouses) do
    data_user = Map.delete(data_user_warehouses, "warehouses")
    data_warehouses = Map.get(data_user_warehouses, "warehouses")

    warehouses_struct = Enum.map(
      data_warehouses,
      fn data_warehouse ->
        Helpers.to_struct_from_string_keyed_map(Warehouse, data_warehouse)
      end
    )

    user_struct = Helpers.to_struct_from_string_keyed_map(User, data_user)
    _user_warehouses_struct = user_struct
    |> Map.put(:warehouses, warehouses_struct)


    user = Repo.get(User, user_id) |> Repo.preload(:warehouses) || %User{}
    changeset = User.changeset(user, data_user)
    Logger.info("Soukosync.Sync: upserting user #{data_user["username"]}")
    log_changeset(changeset)
    user_upsert = Repo.insert_or_update(changeset)





    warehouse_upserts = Enum.map(
      warehouses_struct,
      fn warehouse ->

        case Repo.get(Warehouse, warehouse.id) do
          nil ->
            warehouse = Map.put(warehouse, :users, [user])
            Logger.info("Soukosync.Sync: new warehouse #{warehouse.name}. Associating additional current user #{user.username} and inserting...")
            Repo.insert!(warehouse)
          existing ->
            Logger.info("Soukosync.Sync: found existing warehouse #{existing.name}.")
            existing_preload = existing |> Repo.preload(:users)
            changeset = Warehouse.changeset(existing_preload, Map.from_struct(warehouse))
            log_changeset(changeset)

            existing_users_ids = Enum.map(
              existing_preload.users,
              fn existing_user ->
                existing_user.id
              end
            )

            changeset = if !Enum.member?(existing_users_ids, user.id) do
              Logger.info("    associating additional current user #{user.username}.")
              changeset
              |> Ecto.Changeset.put_assoc(:users, [ user | existing_preload.users ])
            else
              changeset
            end

            Repo.update(changeset)

        end
      end
    )

    upserts = [user_upsert | warehouse_upserts]

    final = if Enum.all?(
      upserts,
      fn {result, _struct_or_changeset} ->
        result == :ok
      end
    ) do
      {:ok, upserts}
    else
      {:error, upserts}
    end

    final
  end


  def log_changeset(changeset) do
    #IO.inspect(changeset.data.__meta__.schema)
    if changeset.changes != %{} do
      Logger.info("    changes: #{inspect changeset.changes}")
    end
  end

end
