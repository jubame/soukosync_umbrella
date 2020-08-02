defmodule Soukosync.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :employee_id, :string
      add :first_name, :string
      add :last_name, :string

      timestamps()
    end

  end
end
