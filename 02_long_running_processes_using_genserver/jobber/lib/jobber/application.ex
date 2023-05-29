defmodule Jobber.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    job_runner_args = [
      strategy: :one_for_one,
      name: Jobber.JobRunner,
      max_seconds: 30
    ]

    children = [
      {DynamicSupervisor, job_runner_args}
    ]

    opts = [strategy: :one_for_one, name: Jobber.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
