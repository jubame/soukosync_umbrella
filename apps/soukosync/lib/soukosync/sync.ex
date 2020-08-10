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

    token_oauth_api = Application.get_env(:soukosync, :token_oauth_api)
    headers = ["Authorization": "Bearer #{token_oauth_api}"]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    with {:ok, user_id} <- Soukosync.Accounts.get_current_user_id(),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(build_user_warehouses_url(user_id), headers, options),
         {:ok, data_user_warehouses} <- Helpers.check_unauthorized(Poison.decode!(body))
    do
      upsert_user_warehouses(user_id, data_user_warehouses)
    end


  end

  defp build_user_warehouses_url(user_id) do
    api_base_url = Application.get_env(:soukosync, :api_base_url)
    path = "iam/users/#{user_id}/warehouses"
    "https://#{api_base_url}/#{path}"
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
