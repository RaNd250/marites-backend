defmodule Marites.FleetTelemetry.ConsumerTest do
  use ExUnit.Case, async: true

  alias Marites.FleetTelemetry.Consumer

  test "extract_fields/1 decodes Soc and ShiftState from payload" do
    payload = %Marites.FleetTelemetry.Payload{
      vin: "5YJ3E1EA1NF000001",
      data: [
        %Marites.FleetTelemetry.Datum{
          key: :Soc,
          value: %Marites.FleetTelemetry.Value{value: {:double_value, 72.5}}
        },
        %Marites.FleetTelemetry.Datum{
          key: :ShiftState,
          value: %Marites.FleetTelemetry.Value{value: {:string_value, "D"}}
        }
      ]
    }

    result = Consumer.extract_fields(payload)

    assert result[:soc] == 72.5
    assert result[:shift_state] == "D"
  end

  test "extract_fields/1 ignores unknown fields" do
    payload = %Marites.FleetTelemetry.Payload{
      vin: "VIN",
      data: [
        %Marites.FleetTelemetry.Datum{
          key: :GearSelector,
          value: %Marites.FleetTelemetry.Value{value: {:string_value, "P"}}
        }
      ]
    }

    result = Consumer.extract_fields(payload)
    # GearSelector is not in @field_map so it should be ignored
    assert result == %{}
  end
end
