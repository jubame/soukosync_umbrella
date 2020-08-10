defmodule Soukosync.Sync do
  @moduledoc """
  The Sync context.
  """

  import Ecto.Query, warn: false
  alias Soukosync.Repo
  alias Soukosync.Helpers
  alias Soukosync.Accounts.User
  alias Soukosync.Warehouses.Warehouse

  def upsert_user_warehouses() do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    token_oauth_api = Application.get_env(:soukosync, :token_oauth_api)

    user_id = Soukosync.Accounts.get_current_user_id()

    path = "iam/users/#{user_id}/warehouses"
    url = "https://#{api_base_url}/#{path}"

    headers = ["Authorization": "Bearer #{token_oauth_api}"]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    data_user_warehouses = HTTPoison.get!(url, headers, options)
    |> Map.get(:body)
    |> Poison.decode!

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

    user = Repo.get(User, user_id) || User.changeset(%User{id: user_id}, data_user)
    |> Repo.insert!(on_conflict: :nothing)



    upserts = Enum.map(
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

            changeset = if !Enum.member?(existing_users_ids, user.id) do
              changeset
              |> Ecto.Changeset.put_assoc(:users, [ user | existing_preload.users ])
            else
              changeset
            end

            Repo.update!(changeset)

        end
      end
    )


    upserts

  end


end
