defmodule SoukosyncWeb.WarehouseView do
  use SoukosyncWeb, :view
  alias SoukosyncWeb.WarehouseView

  def render("index.json", %{warehouses: warehouses}) do
    %{data: render_many(warehouses, WarehouseView, "warehouse.json")}
  end

  def render("show.json", %{warehouse: warehouse}) do
    %{data: render_one(warehouse, WarehouseView, "warehouse.json")}
  end

  def render("warehouse.json", %{warehouse: warehouse}) do
    %{id: warehouse.id,
      name: warehouse.name,
      line1: warehouse.line1,
      line2: warehouse.line2,
      site: warehouse.site,
      city: warehouse.city,
      state: warehouse.state,
      zip_code: warehouse.zip_code,
      country: warehouse.country,
      fax: warehouse.fax,
      phone: warehouse.phone}
  end
end
