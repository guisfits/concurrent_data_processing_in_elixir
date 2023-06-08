defmodule Scraper.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ProducerConsumerRegistry},
      PageProducer,
      # PageConsumer
      # Supervisor.child_spec(PageConsumer, id: :consumer_a),
      # Supervisor.child_spec(PageConsumer, id: :consumer_b)
      # OnlinePageProducerConsumer,
      producer_consumer_spec(id: 1),
      producer_consumer_spec(id: 2),
      PageConsumerSupervisor
    ]

    opts = [strategy: :one_for_one, name: Scraper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def producer_consumer_spec(id: id) do
    id = "online_page_producer_consumer_#{id}"
    Supervisor.child_spec({OnlinePageProducerConsumer, id}, id: id)
  end
end
