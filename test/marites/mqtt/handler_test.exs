defmodule Marites.Mqtt.HandlerTest do
  use ExUnit.Case, async: true

  alias Marites.Mqtt.Handler

  # Ports the still-valid assertions from the deleted
  # Marites.FleetTelemetry.ConsumerTest (FT consumption moved to marites-api;
  # the engine now receives per-field JSON payloads over MQTT).

  test "parse_payload/2 decodes Soc and ShiftState" do
    assert {:ok, :soc, 72.5} = Handler.parse_payload("Soc", "72.5")
    assert {:ok, :shift_state, "D"} = Handler.parse_payload("ShiftState", ~s("ShiftStateD"))
  end

  test "parse_payload/2 decodes RatedRange as a bare number (miles)" do
    assert {:ok, :rated_battery_range, 250.5} = Handler.parse_payload("RatedRange", "250.5")
  end

  # Phase 1 battery-health roadmap: EstBatteryRange/IdealBatteryRange were
  # never in the field map, so est_battery_range_km/ideal_battery_range_km
  # stayed NULL for all FT-era rows despite the DB columns already existing.
  test "parse_payload/2 decodes EstBatteryRange and IdealBatteryRange as bare numbers (miles)" do
    assert {:ok, :est_battery_range, 268.0} = Handler.parse_payload("EstBatteryRange", "268.0")
    assert {:ok, :ideal_battery_range, 315.5} = Handler.parse_payload("IdealBatteryRange", "315.5")
  end

  test "parse_payload/2 decodes temps and Location" do
    assert {:ok, :inside_temp, 21.5} = Handler.parse_payload("InsideTemp", "21.5")

    assert {:ok, :location, %{latitude: 1.0, longitude: 2.0}} =
             Handler.parse_payload("Location", ~s({"latitude": 1.0, "longitude": 2.0}))
  end

  test "parse_payload/2 decodes Gear (modern name for deprecated ShiftState)" do
    assert {:ok, :shift_state, "D"} = Handler.parse_payload("Gear", ~s("ShiftStateD"))
    assert {:ok, :shift_state, "P"} = Handler.parse_payload("Gear", ~s("ShiftStateP"))
  end

  test "parse_payload/2 decodes non-gear ShiftState values as nil (ends drives)" do
    assert {:ok, :shift_state, nil} = Handler.parse_payload("Gear", ~s("ShiftStateInvalid"))
    assert {:ok, :shift_state, nil} = Handler.parse_payload("Gear", ~s("ShiftStateSNA"))
    assert {:ok, :shift_state, nil} = Handler.parse_payload("ShiftState", ~s("ShiftStateUnknown"))
  end

  test "parse_payload/2 decodes sentry threat states as armed (Aware/Panic)" do
    assert {:ok, :sentry_mode, true} = Handler.parse_payload("SentryMode", ~s("SentryModeStateAware"))
    assert {:ok, :sentry_mode, true} = Handler.parse_payload("SentryMode", ~s("SentryModeStatePanic"))
  end

  test "parse_payload/2 skips DetailedChargeStateUnknown (never clobber known state)" do
    assert :skip = Handler.parse_payload("DetailedChargeState", ~s("DetailedChargeStateUnknown"))
  end

  test "parse_payload/2 skips unknown fields" do
    assert :skip = Handler.parse_payload("GearSelector", ~s("P"))
  end

  test "parse_payload/2 skips malformed payloads" do
    assert :skip = Handler.parse_payload("Soc", "not-json")
    assert :skip = Handler.parse_payload("Location", ~s({"latitude": 1.0}))
  end
end
