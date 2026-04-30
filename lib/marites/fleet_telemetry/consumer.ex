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
  @spec extract_fields(Marites.FleetTelemetry.Payload.t()) :: map()
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
    {:ok, %{vin_cache: %{}}, {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    host = Application.get_env(:marites, :fleet_telemetry_mqtt_host, ~c"mosquitto")
    port = Application.get_env(:marites, :fleet_telemetry_mqtt_port, 1883)

    {:ok, _conn} = Tortoise311.Connection.start_link(
      client_id:     "marites_fleet_telemetry",
      server:        {Tortoise311.Transport.Tcp, host: host, port: port},
      handler:       {Marites.FleetTelemetry.MqttHandler, []},
      subscriptions: [{"marites/fleet/#", 0}]
    )

    {:noreply, state}
  end

  @impl true
  # topic_levels = ["marites", "fleet", "<vin>", ...]
  def handle_cast({:mqtt_message, [_, _, vin | _], payload}, %{vin_cache: cache} = state) do
    case Map.get(cache, vin) do
      :not_found ->
        {:noreply, state}

      cached_id ->
        handle_payload(vin, cached_id, payload, cache, state)
    end
  end

  def handle_cast({:mqtt_message, _topic, _payload}, state), do: {:noreply, state}
  def handle_cast(_msg, state), do: {:noreply, state}

  # --- Private ---

  defp handle_payload(vin, cached_car_id, payload, cache, state) do
    with {:ok, car_id}        <- resolve_car_id(vin, cached_car_id, cache),
         {:ok, proto_payload} <- decode(payload) do
      fields = extract_fields(proto_payload)
      Vehicles.handle_fleet_telemetry(car_id, fields)
      {:noreply, %{state | vin_cache: Map.put(cache, vin, car_id)}}
    else
      {:error, :car_not_found} ->
        Logger.warning("FleetTelemetry: vehicle with VIN #{vin} not in DB, skipping")
        {:noreply, %{state | vin_cache: Map.put(cache, vin, :not_found)}}

      {:error, :decode_failed} ->
        {:noreply, state}
    end
  end

  defp resolve_car_id(_vin, car_id, _cache) when is_integer(car_id), do: {:ok, car_id}

  defp resolve_car_id(vin, nil, _cache) do
    case Repo.get_by(Car, vin: vin) do
      nil -> {:error, :car_not_found}
      car -> {:ok, car.id}
    end
  end

  defp decode(binary) do
    {:ok, Marites.FleetTelemetry.Payload.decode(binary)}
  rescue
    e in [Protobuf.DecodeError] ->
      Logger.warning("FleetTelemetry: protobuf decode error: #{inspect(e)}")
      {:error, :decode_failed}
  end

  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:string_value, v}}),   do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:double_value, v}}),   do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:float_value, v}}),    do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:int_value, v}}),      do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:bool_value, v}}),     do: v
  defp unwrap_value(%Marites.FleetTelemetry.Value{value: {:location_value, v}}), do: v
  defp unwrap_value(_), do: nil
end
