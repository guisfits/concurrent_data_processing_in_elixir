defmodule Jobber do
  @moduledoc false

  alias Jobber.{JobRunner, JobSupervisor}

  def start_job(args) do
    DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
  end
end
