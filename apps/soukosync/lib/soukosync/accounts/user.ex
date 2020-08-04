defmodule Soukosync.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :employee_id, :string
    field :first_name, :string
    field :last_name, :string
    field :username, :string
    field :origin_id, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :employee_id, :first_name, :last_name])
    |> validate_required([:username, :email, :employee_id, :first_name, :last_name])
  end
end
