defmodule SoukosyncWeb.SyncView do
  use SoukosyncWeb, :view
  alias SoukosyncWeb.SyncView

  def render("index.json", %{last_syncs: last_syncs}) do
    %{data: render_many(last_syncs, SyncView, "sync.json")}
  end

  def render("sync.json", %{sync: last_sync}) do
    {response, date, data} = last_sync
    %{
      response: response,
      date: date,
      data: IO.inspect(data)
    }
  end
end
