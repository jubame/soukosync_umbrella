defmodule Soukosync.Repo.Migrations.CreateUniqueIndexOriginIdUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, :origin_id)
  end
end
