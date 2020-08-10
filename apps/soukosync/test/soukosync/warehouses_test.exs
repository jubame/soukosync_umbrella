defmodule Soukosync.SyncTest do
  use Soukosync.DataCase

  alias Soukosync.Warehouses

  describe "warehouses" do
    alias Soukosync.Warehouses.Warehouse

    @valid_attrs %{id: 456, city: "some city", country: "some country", fax: "some fax", line1: "some line1", line2: "some line2", name: "some name", phone: "some phone", site: "some site", state: "some state", zip_code: "some zip_code"}
    @update_attrs %{city: "some updated city", country: "some updated country", fax: "some updated fax", line1: "some updated line1", line2: "some updated line2", name: "some updated name", phone: "some updated phone", site: "some updated site", state: "some updated state", zip_code: "some updated zip_code"}
    @invalid_attrs %{city: nil, country: nil, fax: nil, line1: nil, line2: nil, name: nil, phone: nil, site: nil, state: nil, zip_code: nil}

    def warehouse_fixture(attrs \\ %{}) do
      {:ok, warehouse} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Warehouses.create_warehouse()

      warehouse
    end

    test "list_warehouses/0 returns all warehouses" do
      warehouse = warehouse_fixture()
      assert Warehouses.list_warehouses() == [warehouse]
    end

    test "get_warehouse!/1 returns the warehouse with given id" do
      warehouse = warehouse_fixture()
      assert Warehouses.get_warehouse!(warehouse.id) == warehouse
    end

    test "create_warehouse/1 with valid data creates a warehouse" do
      assert {:ok, %Warehouse{} = warehouse} = Warehouses.create_warehouse(@valid_attrs)
      assert warehouse.city == "some city"
      assert warehouse.country == "some country"
      assert warehouse.fax == "some fax"
      assert warehouse.line1 == "some line1"
      assert warehouse.line2 == "some line2"
      assert warehouse.name == "some name"
      assert warehouse.phone == "some phone"
      assert warehouse.site == "some site"
      assert warehouse.state == "some state"
      assert warehouse.zip_code == "some zip_code"
    end

    test "create_warehouse/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Warehouses.create_warehouse(@invalid_attrs)
    end

    test "update_warehouse/2 with valid data updates the warehouse" do
      warehouse = warehouse_fixture()
      assert {:ok, %Warehouse{} = warehouse} = Warehouses.update_warehouse(warehouse, @update_attrs)
      assert warehouse.city == "some updated city"
      assert warehouse.country == "some updated country"
      assert warehouse.fax == "some updated fax"
      assert warehouse.line1 == "some updated line1"
      assert warehouse.line2 == "some updated line2"
      assert warehouse.name == "some updated name"
      assert warehouse.phone == "some updated phone"
      assert warehouse.site == "some updated site"
      assert warehouse.state == "some updated state"
      assert warehouse.zip_code == "some updated zip_code"
    end

    test "update_warehouse/2 with invalid data returns error changeset" do
      warehouse = warehouse_fixture()
      assert {:error, %Ecto.Changeset{}} = Warehouses.update_warehouse(warehouse, @invalid_attrs)
      assert warehouse == Warehouses.get_warehouse!(warehouse.id)
    end

    test "delete_warehouse/1 deletes the warehouse" do
      warehouse = warehouse_fixture()
      assert {:ok, %Warehouse{}} = Warehouses.delete_warehouse(warehouse)
      assert_raise Ecto.NoResultsError, fn -> Warehouses.get_warehouse!(warehouse.id) end
    end

    test "change_warehouse/1 returns a warehouse changeset" do
      warehouse = warehouse_fixture()
      assert %Ecto.Changeset{} = Warehouses.change_warehouse(warehouse)
    end
  end
end
