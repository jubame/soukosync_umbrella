defmodule Soukosync.Repo.Migrations.AddOriginIdToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :origin_id, :string
    end
  end
end
