defmodule Soukosync.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: false}
  schema "users" do
    field :email, :string
    field :employee_id, :string
    field :first_name, :string
    field :last_name, :string
    field :username, :string
    field :origin_id, :integer
    many_to_many :warehouses, Soukosync.Warehouses.Warehouse, join_through: "users_warehouses", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    #IO.puts("DENTRO DE USER CHANGESET")
    #IO.inspect(attrs)
    user
    #|> Soukosync.Repo.preload(:warehouses)
    |> cast(attrs, [:id, :username, :email, :employee_id, :first_name, :last_name])
    |> validate_required([:id, :username, :email, :employee_id, :first_name, :last_name])
    |> unique_constraint(:id, name: :users_pkey)
  end
end
