defmodule Throttlex.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [worker(Throttlex, [[name: :throttlex]])]

    opts = [strategy: :one_for_one, name: Throttlex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end