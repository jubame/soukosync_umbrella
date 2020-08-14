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

    with {:ok, data_user_warehouses} <- Soukosync.API.get_user_warehouses(user_id) do
      upsert_user_warehouses(user_id, data_user_warehouses)
    end
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


    Logger.error "user_id: #{user_id}"
    user = Repo.get(User, user_id) |> Repo.preload(:warehouses) || %User{}

    # multi = Ecto.Multi.new()


    changeset = User.changeset(user, data_user)
    Logger.info("Soukosync.Sync: upserting user #{data_user["username"]}")
    log_changeset(changeset)

    #multi = multi |> Ecto.Multi.insert_or_update(:user, changeset)
    {_result_upsert_user, user_upsert} = Repo.insert_or_update(changeset)








    multi = Enum.reduce(
      warehouses_struct,
      Ecto.Multi.new(),
      fn warehouse, multi ->

        case Repo.get(Warehouse, warehouse.id) do
          nil ->
            warehouse = Map.put(warehouse, :users, [user_upsert])
            Logger.info("Soukosync.Sync: new warehouse #{warehouse.name}. Associating additional current user #{user.username} and inserting...")
            Ecto.Multi.insert(multi, warehouse.name, warehouse)
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
              |> Ecto.Changeset.put_assoc(:users, [ user_upsert | existing_preload.users ])
            else
              changeset
            end

            IO.inspect(multi)

            Ecto.Multi.update(multi, existing.name, changeset)

        end
      end
    )

    multi
    |> Repo.transaction()

    # upserts = warehouse_upserts # [{result_upsert_user, user_upsert} | warehouse_upserts]


    # final = if Enum.all?(
    #   upserts,
    #   fn {result, _struct_or_changeset} ->
    #     result == :ok
    #   end
    # ) do
    #   {:ok, upserts}
    # else
    #   {:error, upserts}
    # end

    # final
  end




  def log_changeset(changeset) do
    #IO.inspect(changeset.data.__meta__.schema)
    if changeset.changes != %{} do
      Logger.info("    changes: #{inspect changeset.changes}")
    end
  end

end
