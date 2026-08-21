defmodule Marites.Mqtt.Handler do
  use Tortoise311.Handler

  require Logger

  alias Marites.{Log, Vehicles}

  @field_map %{
    "Soc"                => :soc,
    "Location"           => :location,
    "ShiftState"         => :shift_state,
    "Gear"               => :shift_state,
    "DetailedChargeState" => :charge_state,
    "VehicleSpeed"       => :speed,
    "Odometer"           => :odometer,
    "RatedRange"         => :rated_battery_range,
    "EstBatteryRange"    => :est_battery_range,
    "IdealBatteryRange"  => :ideal_battery_range,
    "InsideTemp"         => :inside_temp,
    "OutsideTemp"        => :outside_temp,
    "SentryMode"         => :sentry_mode,
    "TpmsPressureFl"     => :tpms_pressure_fl,
    "TpmsPressureFr"     => :tpms_pressure_fr,
    "TpmsPressureRl"     => :tpms_pressure_rl,
    "TpmsPressureRr"     => :tpms_pressure_rr
  }

  @impl true
  def connection(:up, state) do
    Logger.info("MQTT connection has been established")
    {:ok, state}
  end

  def connection(:down, state) do
    Logger.warning("MQTT connection has been dropped")
    {:ok, state}
  end

  def connection(:terminating, state) do
    Logger.warning("MQTT connection is terminating")
    {:ok, state}
  end

  @impl true
  def handle_message(topic, payload, state) do
    case parse_topic(topic) do
      {:ok, vin, field_name} ->
        case parse_payload(field_name, payload) do
          {:ok, field_atom, value} -> dispatch(vin, field_atom, value)
          :skip -> :ok
        end
      :skip ->
        :ok
    end

    {:ok, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.warning("MQTT Client has been terminated: #{inspect(reason)}")
    :ok
  end

  # Private

  defp parse_topic(["marites", "fleet", vin, "v", field_name]), do: {:ok, vin, field_name}
  defp parse_topic(_), do: :skip

  @doc false
  def parse_payload(field_name, payload) do
    with {:ok, field_atom} <- Map.fetch(@field_map, field_name),
         {:ok, value} <- decode_value(field_atom, payload) do
      {:ok, field_atom, value}
    else
      _ -> :skip
    end
  end

  defp decode_value(:location, payload) do
    case Jason.decode(payload) do
      {:ok, %{"latitude" => lat, "longitude" => lng}} -> {:ok, %{latitude: lat, longitude: lng}}
      _ -> :error
    end
  end

  defp decode_value(field, payload) when field in [:soc, :speed, :odometer, :inside_temp, :outside_temp, :rated_battery_range, :est_battery_range, :ideal_battery_range, :tpms_pressure_fl, :tpms_pressure_fr, :tpms_pressure_rl, :tpms_pressure_rr] do
    case Jason.decode(payload) do
      {:ok, val} when is_number(val) -> {:ok, val}
      _ -> :error
    end
  end

  # SentryMode arrives as "SentryModeStateOn" / "SentryModeStateOff"
  defp decode_value(:sentry_mode, payload) do
    case Jason.decode(payload) do
      {:ok, "SentryModeStateOn"}    -> {:ok, true}
      {:ok, "SentryModeStateArmed"}  -> {:ok, true}
      {:ok, "SentryModeStateAware"}  -> {:ok, true}
      {:ok, "SentryModeStatePanic"}  -> {:ok, true}
      {:ok, "SentryModeStateOff"}    -> {:ok, false}
      {:ok, val} when is_boolean(val) -> {:ok, val}
      _ -> :error
    end
  end

  # Gear (and its deprecated alias ShiftState) arrives as "ShiftStateD" etc.
  # Non-gear states decode to nil so the vehicle state machine can end drives.
  defp decode_value(:shift_state, payload) do
    case Jason.decode(payload) do
      {:ok, "ShiftStateD"} -> {:ok, "D"}
      {:ok, "ShiftStateR"} -> {:ok, "R"}
      {:ok, "ShiftStateN"} -> {:ok, "N"}
      {:ok, "ShiftStateP"} -> {:ok, "P"}
      {:ok, "ShiftStateUnknown"} -> {:ok, nil}
      {:ok, "ShiftStateInvalid"} -> {:ok, nil}
      {:ok, "ShiftStateSNA"}     -> {:ok, nil}
      {:ok, val} when is_binary(val) -> {:ok, val}
      _ -> :error
    end
  end

  # DetailedChargeState arrives as "DetailedChargeStateCharging" etc.
  defp decode_value(:charge_state, payload) do
    case Jason.decode(payload) do
      {:ok, "DetailedChargeStateUnknown"}      -> :error
      {:ok, "DetailedChargeStateCharging"}     -> {:ok, "Charging"}
      {:ok, "DetailedChargeStateComplete"}     -> {:ok, "Complete"}
      {:ok, "DetailedChargeStateStopped"}      -> {:ok, "Stopped"}
      {:ok, "DetailedChargeStateStarting"}     -> {:ok, "Starting"}
      {:ok, "DetailedChargeStateDisconnected"} -> {:ok, "Disconnected"}
      {:ok, "DetailedChargeStateNoPower"}      -> {:ok, "NoPower"}
      {:ok, val} when is_binary(val) -> {:ok, val}
      _ -> :error
    end
  end

  defp dispatch(vin, field_atom, value) do
    case Log.get_car_by(vin: vin) do
      nil -> Logger.debug("Fleet telemetry: unknown VIN #{vin}")
      car -> Vehicles.handle_fleet_telemetry(car.id, [{field_atom, value}])
    end
  end
end
