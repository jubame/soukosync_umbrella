defmodule Soukosync.SyncTest do
  require Logger
  import DateTime
  use Soukosync.DataCase
  use ExVCR.Mock,
    adapter: ExVCR.Adapter.Hackney

  alias Soukosync.Warehouses
  alias Soukosync.Sync
  alias Soukosync.Accounts.User

  setup_all do
    HTTPoison.start
  end


  describe "users_warehouses" do
    alias Soukosync.Warehouses.Warehouse
    @user_valid_attrs %{id: 123, email: "some email", employee_id: "some employee_id", first_name: "some first_name", last_name: "some last_name", username: "some username"}
    @warehouse_valid_attrs %{id: 456, city: "some city", country: "some country", fax: "some fax", line1: "some line1", line2: "some line2", name: "some name", phone: "some phone", site: "some site", state: "some state", zip_code: "some zip_code"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@user_valid_attrs)
        |> Accounts.create_user()

      user
    end

    def warehouse_fixture(attrs \\ %{}) do
      {:ok, warehouse} =
        attrs
        |> Enum.into(@warehouse_valid_attrs)
        |> Warehouses.create_warehouse()

      warehouse
    end


    test "upsert_user_warehouses/0 inserts the current user and its warehouses on an empty DB" do
      use_cassette "iam_users__user_id__warehouses" do
        ExVCR.Config.filter_request_headers("Authorization")
        inserts = Sync.upsert_user_warehouses()
        assert length(inserts) == 5
      end
    end


    test "upsert_user_warehouses/0 inserts new warehouses and updates present ones" do
      use_cassette "iam_users__user_id__warehouses" do
        ExVCR.Config.filter_request_headers("Authorization")

        first_upsert = Sync.upsert_user_warehouses()
        [warehouse_to_delete, warehouse_to_update] = Repo.all(from x in Warehouse, order_by: [desc: x.id], limit: 2)

        Repo.delete(warehouse_to_delete)

        changed_name = "changed_name_#{DateTime.to_string(DateTime.utc_now)}"

        warehouse_to_update
        |> Warehouse.changeset(%{name: changed_name})
        |> Repo.update()

        second_upsert = Sync.upsert_user_warehouses()

        # Has deleted warehouse been reinserted?
        reinserted_warehouse = Enum.find(
          second_upsert,
          fn upsert ->
            warehouse_to_delete.id == upsert.id
          end
        )
        # Has changed name been changed back to its original value?
        reupdated_warehouse = Enum.find(
          second_upsert,
          fn upsert ->
            warehouse_to_update.name == upsert.name
          end
        )

        assert reinserted_warehouse != nil
        assert reupdated_warehouse != nil
        assert length(first_upsert) == 5
      end
    end


    test "upsert_user_warehouses/0 updates warehouse users for an already associated to a user warehouse" do
      use_cassette "iam_users__user_id__warehouses" do
        ExVCR.Config.filter_request_headers("Authorization")
        inserted_warehouses = Sync.upsert_user_warehouses()
        new_user_warehouses = Repo.all(from x in Warehouse, order_by: [desc: x.id], limit: 2)
        another_warehouse = warehouse_fixture(@warehouse_valid_attrs)

        new_user_warehouses_ids = Enum.map(
          new_user_warehouses,
          fn warehouse ->
            warehouse.id
          end
        )

        not_to_delete_warehouse_ids = [another_warehouse.id | new_user_warehouses_ids]

        from(w in Warehouse, where: w.id not in ^not_to_delete_warehouse_ids) |> Repo.delete_all()
        user = Repo.one(from(u in User))
        Repo.delete(user)

        new_user = User.changeset(%User{}, @user_valid_attrs)
        |> put_assoc(:warehouses, new_user_warehouses)
        |> Repo.insert!()

        Sync.upsert_user_warehouses()

        common_users_ids_warehouses_with_two_users = from(
          w in Warehouse,
          where: w.id in ^new_user_warehouses_ids,
          join: u in assoc(w, :users),
          group_by: u.id,
          select: u.id
        ) |> Repo.all()

        assert Enum.member?(common_users_ids_warehouses_with_two_users, user.id) and
               Enum.member?(common_users_ids_warehouses_with_two_users, new_user.id)

      end
    end



  end
end
