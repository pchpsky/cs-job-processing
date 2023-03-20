defmodule JobsService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      JobsServiceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: JobsService.PubSub},
      # Start the Endpoint (http/https)
      JobsServiceWeb.Endpoint
      # Start a worker by calling: JobsService.Worker.start_link(arg)
      # {JobsService.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JobsService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JobsServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
