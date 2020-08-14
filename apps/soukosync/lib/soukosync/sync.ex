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

    changeset = User.changeset(user, data_user)
    Logger.info("Soukosync.Sync: upserting user #{data_user["username"]}")
    log_changeset(changeset)

    multi = Ecto.Multi.new() |> Ecto.Multi.insert_or_update(:user, changeset)
    #{_result_upsert_user, user_upsert} = Repo.insert_or_update(changeset)


    # Ecto.Multi.run/5 format: https://stackoverflow.com/a/40747098/12315725






    multi = Enum.reduce(
      warehouses_struct,
      multi,
      fn warehouse, multi ->

        case Repo.get(Warehouse, warehouse.id) do
          nil ->
            Ecto.Multi.run(multi, "warehouse_#{warehouse.id}", Soukosync.Sync, :insert_warehouse, [warehouse])
          existing ->
            Ecto.Multi.run(multi, "warehouse_#{existing.id}", Soukosync.Sync, :update_warehouse, [existing])
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

  def insert_warehouse(_repo, %{user: user}, warehouse) do
    warehouse = Map.put(warehouse, :users, [user])
    Logger.info("Soukosync.Sync: new warehouse #{warehouse.name}. Associating additional current user #{user.username} and inserting...")
    Repo.insert(warehouse)
  end

  def update_warehouse(_repo, %{user: user}, existing) do
    Logger.info("Soukosync.Sync: found existing warehouse #{existing.name}.")
    existing_preload = existing |> Repo.preload(:users)
    changeset = Warehouse.changeset(existing_preload, Map.from_struct(existing))
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



  def log_changeset(changeset) do
    #IO.inspect(changeset.data.__meta__.schema)
    if changeset.changes != %{} do
      Logger.info("    changes: #{inspect changeset.changes}")
    end
  end

end
