defmodule SAML.Supervisor do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(SAML.Cache, [])
    ]

    opts = [strategy: :one_for_one, name: SAML.Supervisor]
    Supervisor.start_link(children, opts)
  end
end