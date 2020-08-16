defmodule SoukosyncWeb.SyncView do
  use SoukosyncWeb, :view
  alias SoukosyncWeb.SyncView

  def render("index.json", %{last_syncs: last_syncs}) do
    %{data: render_many(last_syncs, SyncView, "sync.json")}
  end


  def render("sync.json", %{sync: {:error, message}}) do
    %{
      response: :error,
      data: message
    }
  end

  def render("sync.json", %{sync: :empty}) do
    %{
      data: "empty"
    }
  end

  def render("sync.json", %{sync: {:value, {response, date, data}}}) do
    %{
      response: response,
      date: date,
      data: IO.inspect(data)
    }
  end

  def render("sync.json", %{sync: {response, date, data}}) do
    %{
      response: response,
      date: date,
      data: IO.inspect(data)
    }
  end

end
