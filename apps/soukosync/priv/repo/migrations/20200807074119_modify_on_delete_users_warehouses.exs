defmodule Soukosync.Repo.Migrations.ModifyOnDeleteUsersWarehouses do
  use Ecto.Migration

  # https://elixirforum.com/t/can-you-modify-a-columns-references-3-options-in-ecto/4443/10
  def change do
    alter table(:users_warehouses) do
      modify :user_id, references(:users, on_delete: :delete_all),
        from: references(:users, on_delete: :nothing)
      modify :warehouse_id, references(:warehouses, on_delete: :delete_all),
        from: references(:warehouses, on_delete: :nothing)
    end
  end
end
