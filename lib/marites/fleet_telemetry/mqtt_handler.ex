defmodule Marites.FleetTelemetry.MqttHandler do
  use Tortoise311.Handler

  @impl true
  def init(_opts), do: {:ok, []}

  # topic_levels is a list of binary segments e.g. ["marites", "fleet", "<vin>"]
  @impl true
  def handle_message(topic_levels, payload, state) do
    GenServer.cast(Marites.FleetTelemetry.Consumer, {:mqtt_message, topic_levels, payload})
    {:ok, state}
  end

  @impl true
  def connection(_status, state), do: {:ok, state}

  @impl true
  def terminate(_reason, _state), do: :ok
end
