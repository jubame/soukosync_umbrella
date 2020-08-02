defmodule SoukosyncWeb.WarehouseControllerTest do
  use SoukosyncWeb.ConnCase

  alias Soukosync.Sync
  alias Soukosync.Sync.Warehouse

  @create_attrs %{
    city: "some city",
    country: "some country",
    fax: "some fax",
    line1: "some line1",
    line2: "some line2",
    name: "some name",
    phone: "some phone",
    site: "some site",
    state: "some state",
    zip_code: "some zip_code"
  }
  @update_attrs %{
    city: "some updated city",
    country: "some updated country",
    fax: "some updated fax",
    line1: "some updated line1",
    line2: "some updated line2",
    name: "some updated name",
    phone: "some updated phone",
    site: "some updated site",
    state: "some updated state",
    zip_code: "some updated zip_code"
  }
  @invalid_attrs %{city: nil, country: nil, fax: nil, line1: nil, line2: nil, name: nil, phone: nil, site: nil, state: nil, zip_code: nil}

  def fixture(:warehouse) do
    {:ok, warehouse} = Sync.create_warehouse(@create_attrs)
    warehouse
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all warehouses", %{conn: conn} do
      conn = get(conn, Routes.warehouse_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create warehouse" do
    test "renders warehouse when data is valid", %{conn: conn} do
      conn = post(conn, Routes.warehouse_path(conn, :create), warehouse: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.warehouse_path(conn, :show, id))

      assert %{
               "id" => id,
               "city" => "some city",
               "country" => "some country",
               "fax" => "some fax",
               "line1" => "some line1",
               "line2" => "some line2",
               "name" => "some name",
               "phone" => "some phone",
               "site" => "some site",
               "state" => "some state",
               "zip_code" => "some zip_code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.warehouse_path(conn, :create), warehouse: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update warehouse" do
    setup [:create_warehouse]

    test "renders warehouse when data is valid", %{conn: conn, warehouse: %Warehouse{id: id} = warehouse} do
      conn = put(conn, Routes.warehouse_path(conn, :update, warehouse), warehouse: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.warehouse_path(conn, :show, id))

      assert %{
               "id" => id,
               "city" => "some updated city",
               "country" => "some updated country",
               "fax" => "some updated fax",
               "line1" => "some updated line1",
               "line2" => "some updated line2",
               "name" => "some updated name",
               "phone" => "some updated phone",
               "site" => "some updated site",
               "state" => "some updated state",
               "zip_code" => "some updated zip_code"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, warehouse: warehouse} do
      conn = put(conn, Routes.warehouse_path(conn, :update, warehouse), warehouse: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete warehouse" do
    setup [:create_warehouse]

    test "deletes chosen warehouse", %{conn: conn, warehouse: warehouse} do
      conn = delete(conn, Routes.warehouse_path(conn, :delete, warehouse))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.warehouse_path(conn, :show, warehouse))
      end
    end
  end

  defp create_warehouse(_) do
    warehouse = fixture(:warehouse)
    {:ok, warehouse: warehouse}
  end
end
