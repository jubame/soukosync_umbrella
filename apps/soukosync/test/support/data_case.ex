defmodule Soukosync.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use SoukosyncWeb.DataCase, async: true`, although
  this option is not recommendded for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Soukosync.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Soukosync.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Soukosync.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Soukosync.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end


  def same_ids?(warehouses, transaction_changes) do
    transaction_warehouse_ids = get_warehouse_ids(transaction_changes)
    warehouse_ids = Enum.map(
      warehouses,
      fn warehouse -> warehouse.id end
    )
    # https://stackoverflow.com/a/47695540/12315725
    Enum.sort(warehouse_ids) == Enum.sort(transaction_warehouse_ids)
  end

  def get_warehouse_ids(transaction_changes) do
    Enum.reduce(
      transaction_changes,
      [],
      fn
        {_key, %Soukosync.Warehouses.Warehouse{} = value}, acc -> [ value.id | acc]
        {_key, _value}, acc -> acc
      end
    )
  end

end
