defmodule SendServer do
  use GenServer

  # * Public API

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def send(email) do
    GenServer.cast(__MODULE__, {:send, email})
  end

  def send_batch(emails) do
    emails
    |> Enum.each(&send/1)

    :ok
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  # * GenServer Callbacks

  @impl true
  def init(initial_args) do
    IO.puts("Received arguments: #{inspect(initial_args)}")
    max_retries = Keyword.get(initial_args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}
    Process.send_after(self(), :retry, 5000)

    {:ok, state}
  end

  @impl true
  def handle_cast({:send, email}, state) do
    status =
      email
      |> Sender.send_email()
      |> get_status_from_send_email()

    emails = [%{email: email, status: status, retries: 0}] ++ state.emails

    {:noreply, %{state | emails: emails}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:retry, state) do
    {failed, done} =
      Enum.split_with(state.emails, fn item ->
        item.status == "failed" && item.retries < state.max_retries
      end)

    retried =
      Enum.map(failed, fn item ->
        IO.puts("Retrying email to #{item.email}")

        new_status =
          item.email
          |> Sender.send_email()
          |> get_status_from_send_email()

        %{email: item.email, status: new_status, retries: item.retries + 1}
      end)

    Process.send_after(self(), :retry, 5000)

    {:noreply, %{state | emails: retried ++ done}}
  end

  @impl true
  def terminate(reason, _state) do
    IO.puts("Terminating with reason #{reason}")
  end

  # * Helpers

  defp get_status_from_send_email({:ok, "email_sent"}), do: "sent"
  defp get_status_from_send_email(:error), do: "failed"
end
