defmodule SoukosyncWeb.UserView do
  use SoukosyncWeb, :view
  alias SoukosyncWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      email: user.email,
      employee_id: user.employee_id,
      first_name: user.first_name,
      last_name: user.last_name}
  end
end
