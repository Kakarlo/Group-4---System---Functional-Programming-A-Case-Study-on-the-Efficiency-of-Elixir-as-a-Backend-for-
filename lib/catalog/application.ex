defmodule Catalog.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Catalog.Repo
    ]
    opts = [strategy: :one_for_one, name: Catalog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
