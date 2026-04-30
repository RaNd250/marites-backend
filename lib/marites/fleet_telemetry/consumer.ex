defmodule Marites.FleetTelemetry.Consumer do
  use GenServer
  require Logger

  alias Marites.{Repo, Vehicles}
  alias Marites.Log.Car

  @field_map %{
    Soc:          :soc,
    ShiftState:   :shift_state,
    ChargeState:  :charge_state,
    SentryMode:   :sentry_mode,
    VehicleSpeed: :speed,
    Odometer:     :odometer,
    Location:     :location
  }

  # --- Public API ---

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @doc "Extracts decoded fields map from a decoded Payload struct."
  def extract_fields(%Marites.FleetTelemetry.Payload{data: data}) do
    Enum.reduce(data, %{}, fn %Marites.FleetTelemetry.Datum{key: key, value: val}, acc ->
      case Map.get(@field_map, key) do
        nil   -> acc
        field -> Map.put(acc, field, unwrap_value(val))
      end
    end)
  end

  # --- GenServer callbacks ---

  @impl true
  def init(_opts) do
    host = Application.get_env(:marites, :fleet_telemetry_mqtt_host, ~c"mosquitto")
    port = Application.get_env(:marites, :fleet_telemetry_mqtt_port, 1883)

    {:ok, _conn} = Tortoise311.Connection.start_link(
      client_id:     "marites_fleet_telemetry",
      server:        {Tortoise311.Transport.Tcp, host: host, port: port},
      handler:       {Marites.FleetTelemetry.MqttHandler, []},
      subscriptions: [{"marites/fleet/#", 0}]
    )

    {:ok, %{vin_cache: %{}}}
  end

  @impl true
  def handle_cast({:mqtt_message, topic, payload}, %{vin_cache: cache} = state) do
    with [_, _, vin | _] <- String.split(topic, "/"),
         {:ok, proto_payload} <- decode(payload),
         {:ok, car_id}        <- resolve_car_id(vin, cache) do
      fields = extract_fields(proto_payload)
      Vehicles.handle_fleet_telemetry(car_id, fields)
      {:noreply, %{state | vin_cache: Map.put(cache, vin, car_id)}}
    else
      _ ->
        Logger.debug("FleetTelemetry.Consumer: skipped topic #{topic}")
        {:noreply, state}
    end
  end

  def handle_cast(_msg, state), do: {:noreply, state}

  # --- Private ---

  defp decode(binary) do
    {:ok, Marites.FleetTelemetry.Payload.decode(binary)}
  rescue
    _ -> {:error, :decode_failed}
  end

  defp resolve_car_id(vin, cache) do
    case Map.get(cache, vin) do
      nil ->
        case Repo.get_by(Car, vin: vin) do
          nil -> {:error, :car_not_found}
          car -> {:ok, car.id}
        end

      car_id ->
        {:ok, car_id}
    end
  end

  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:string_value, v}}),   do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:double_value, v}}),   do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:float_value, v}}),    do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:int_value, v}}),      do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:bool_value, v}}),     do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:location_value, v}}), do: v
  defp unwrap_value(_), do: nil
end
