defmodule Soukosync.Repo.Migrations.ModifyOriginIdUsers do
  use Ecto.Migration

  # https://elixirforum.com/t/postgrex-error-error-42804-datatype-mismatch-column-cannot-be-cast-automatically-to-type-integer/16776/2
  def up do
    execute """
      alter table users alter column origin_id type integer using (origin_id::integer)
     """
 end

 def down do
    execute """
      alter table users alter column origin_id type character varying(255);
     """
 end
end
