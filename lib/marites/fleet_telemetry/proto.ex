defmodule Marites.FleetTelemetry.Field do
  use Protobuf, enum: true, syntax: :proto3

  field :Unknown,              0
  field :ChargeState,          2
  field :VehicleSpeed,         4
  field :Odometer,             5
  field :Soc,                  8
  field :Gear,                10
  field :Location,            21
  field :SentryMode,          65
  field :DetailedChargeState, 179
end

defmodule Marites.FleetTelemetry.ShiftState do
  use Protobuf, enum: true, syntax: :proto3

  field :ShiftStateUnknown, 0
  field :ShiftStateInvalid, 1
  field :ShiftStateP,       2
  field :ShiftStateR,       3
  field :ShiftStateN,       4
  field :ShiftStateD,       5
  field :ShiftStateSNA,     6
end

defmodule Marites.FleetTelemetry.DetailedChargeStateValue do
  use Protobuf, enum: true, syntax: :proto3

  field :DetailedChargeStateUnknown,       0
  field :DetailedChargeStateDisconnected,  1
  field :DetailedChargeStateNoPower,       2
  field :DetailedChargeStateStarting,      3
  field :DetailedChargeStateCharging,      4
  field :DetailedChargeStateComplete,      5
  field :DetailedChargeStateStopped,       6
end

defmodule Marites.FleetTelemetry.Location do
  use Protobuf, syntax: :proto3

  field :latitude,  1, type: :double
  field :longitude, 2, type: :double
end

defmodule Marites.FleetTelemetry.Value do
  use Protobuf, syntax: :proto3

  oneof :value, 0

  field :string_value,                 1, type: :string,                                           oneof: 0
  field :int_value,                    2, type: :int64,                                            oneof: 0
  field :double_value,                 3, type: :double,                                           oneof: 0
  field :bool_value,                   4, type: :bool,                                             oneof: 0
  field :location_value,               5, type: Marites.FleetTelemetry.Location,                   oneof: 0
  field :float_value,                  6, type: :float,                                            oneof: 0
  field :shift_state_value,            9, type: Marites.FleetTelemetry.ShiftState,                 enum: true, oneof: 0
  field :detailed_charge_state_value, 32, type: Marites.FleetTelemetry.DetailedChargeStateValue,   enum: true, oneof: 0
end

defmodule Marites.FleetTelemetry.Datum do
  use Protobuf, syntax: :proto3

  field :key,   1, type: Marites.FleetTelemetry.Field, enum: true
  field :value, 2, type: Marites.FleetTelemetry.Value
end

defmodule Marites.FleetTelemetry.Payload do
  use Protobuf, syntax: :proto3

  field :vin,  1, type: :string
  field :txid, 4, type: :string
  field :data, 2, repeated: true, type: Marites.FleetTelemetry.Datum
end
