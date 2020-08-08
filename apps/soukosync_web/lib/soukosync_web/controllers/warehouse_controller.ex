defmodule SoukosyncWeb.WarehouseController do
  use SoukosyncWeb, :controller

  alias Soukosync.Warehouses
  alias Soukosync.Warehouses.Warehouse

  action_fallback SoukosyncWeb.FallbackController

  def index(conn, _params) do
    warehouses = Warehouses.list_warehouses()
    render(conn, "index.json", warehouses: warehouses)
  end

  def create(conn, %{"warehouse" => warehouse_params}) do
    with {:ok, %Warehouse{} = warehouse} <- Warehouses.create_warehouse(warehouse_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.warehouse_path(conn, :show, warehouse))
      |> render("show.json", warehouse: warehouse)
    end
  end

  def show(conn, %{"id" => id}) do
    warehouse = Warehouses.get_warehouse!(id)
    render(conn, "show.json", warehouse: warehouse)
  end

  def update(conn, %{"id" => id, "warehouse" => warehouse_params}) do
    warehouse = Warehouses.get_warehouse!(id)

    with {:ok, %Warehouse{} = warehouse} <- Warehouses.update_warehouse(warehouse, warehouse_params) do
      render(conn, "show.json", warehouse: warehouse)
    end
  end

  def delete(conn, %{"id" => id}) do
    warehouse = Warehouses.get_warehouse!(id)

    with {:ok, %Warehouse{}} <- Warehouses.delete_warehouse(warehouse) do
      send_resp(conn, :no_content, "")
    end
  end
end
