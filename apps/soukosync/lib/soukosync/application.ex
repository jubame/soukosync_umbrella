defmodule Soukosync.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Soukosync.Repo,
      {Soukosync.Scheduler, 0},
      {Soukosync.Caller, 0}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Soukosync.Supervisor)
  end
end
