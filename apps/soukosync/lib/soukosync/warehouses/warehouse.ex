defmodule Soukosync.Warehouses.Warehouse do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: false}
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
    field :origin_id, :integer
    many_to_many :users, Soukosync.Accounts.User, join_through: "users_warehouses", on_replace: :mark_as_invalid

    timestamps()
  end

  @doc false
  def changeset(warehouse, attrs) do
    #IO.puts("DENTRO DE WAREHOUSE CHANGESET")
    #IO.inspect(warehouse)

    warehouse
    |> cast(attrs, [:id, :name, :line1, :line2, :site, :city, :state, :zip_code, :country, :fax, :phone])
    |> validate_required([:id, :name, :line1])
  end
end
