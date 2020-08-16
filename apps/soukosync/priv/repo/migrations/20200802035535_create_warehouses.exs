defmodule Soukosync.Repo.Migrations.CreateWarehouses do
  use Ecto.Migration

  def change do
    create table(:warehouses) do
      add :name, :string
      add :line1, :string
      add :line2, :string
      add :site, :string
      add :city, :string
      add :state, :string
      add :zip_code, :string
      add :country, :string
      add :fax, :string
      add :phone, :string

      timestamps()
    end

  end
end
