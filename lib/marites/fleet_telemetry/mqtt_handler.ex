defmodule Marites.FleetTelemetry.MqttHandler do
  use Tortoise311.Handler

  @impl true
  def init(_opts), do: {:ok, []}

  @impl true
  def handle_message(topic, payload, state) do
    GenServer.cast(Marites.FleetTelemetry.Consumer, {:mqtt_message, topic, payload})
    {:ok, state}
  end

  @impl true
  def connection(_status, state), do: {:ok, state}

  @impl true
  def terminate(_reason, _state), do: :ok
end
