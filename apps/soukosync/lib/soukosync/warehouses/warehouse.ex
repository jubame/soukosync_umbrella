defmodule Soukosync.Warehouses.Warehouse do
  use Ecto.Schema
  import Ecto.Changeset

  schema "warehouses" do
    field :city, :string
    field :country, :string
    field :fax, :string
    field :line1, :string
    field :line2, :string
    field :name, :string
    field :phone, :string
    field :site, :string
    field :state, :string
    field :zip_code, :string

    timestamps()
  end

  @doc false
  def changeset(warehouse, attrs) do
    warehouse
    |> cast(attrs, [:name, :line1, :line2, :site, :city, :state, :zip_code, :country, :fax, :phone])
    |> validate_required([:name, :line1, :line2, :site, :city, :state, :zip_code, :country, :fax, :phone])
  end
end
