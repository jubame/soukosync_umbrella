defmodule SoukosyncWeb.SyncView do
  use SoukosyncWeb, :view
  alias SoukosyncWeb.SyncView


  def render("sync.json", %{last_sync: last_sync}) do
    {response, date, data} = last_sync
    %{
      response: response,
      date: date,
      data: IO.inspect(data)
    }
  end


  def render("sync.json", %{message: message}) do
    %{
      message: message
    }
  end
end
