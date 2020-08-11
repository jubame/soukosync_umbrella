defmodule SoukosyncWeb.SyncView do
  use SoukosyncWeb, :view
  alias SoukosyncWeb.SyncView



  def render("sync.json", sync) do
    %{
      message: sync.message
    }
  end
end
