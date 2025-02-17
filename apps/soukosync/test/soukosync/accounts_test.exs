defmodule Soukosync.AccountsTest do
  require Logger
  use Soukosync.DataCase
  use ExVCR.Mock,
    adapter: ExVCR.Adapter.Hackney

  alias Soukosync.Accounts


  setup_all do
    HTTPoison.start
  end


  describe "users" do
    alias Soukosync.Accounts.User

    @valid_attrs %{id: 1, email: "some email", employee_id: "some employee_id", first_name: "some first_name", last_name: "some last_name", username: "some username"}
    @update_attrs %{email: "some updated email", employee_id: "some updated employee_id", first_name: "some updated first_name", last_name: "some updated last_name", username: "some updated username"}
    @invalid_attrs %{email: nil, employee_id: nil, first_name: nil, last_name: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end



    test "get_current_user_id/0 returns the id from the currently authenticated user" do

      '''
      user_id = Accounts.get_current_user_id()
      IO.inspect(user_id)
      assert user_id == 233
      '''

      use_cassette "iam_users_me" do
        ExVCR.Config.filter_request_headers("Authorization")
        {:ok, user} = Accounts.get_current_user()
        assert user.id == 233
      end
    end



    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.employee_id == "some employee_id"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.employee_id == "some updated employee_id"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
