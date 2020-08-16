defmodule Soukosync.Repo.Migrations.AddOriginIdToWarehouses do
  use Ecto.Migration

  def change do
    alter table(:warehouses) do
      add :origin_id, :integer
    end
  end
end
