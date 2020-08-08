defmodule Soukosync.SyncTest do
  use Soukosync.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  alias Soukosync.Warehouses

  setup_all do
    :inets.start
  end


  describe "warehouses" do
    alias Soukosync.Warehouses.Warehouse
  end
end
