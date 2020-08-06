defmodule Soukosync.Repo.Migrations.AddUsersWarehousesTable do
  use Ecto.Migration

  def change do
    create table(:users_warehouses, primary_key: false) do
      add :user_id, references(:users)
      add :warehouse_id, references(:warehouses)
    end
  end
end
