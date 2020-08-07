defmodule Soukosync.Repo.Migrations.CreateUniqueIndexUsersWarehouses do
  use Ecto.Migration

  def change do
    create unique_index(:users_warehouses, [:user_id, :warehouse_id])
  end
end
