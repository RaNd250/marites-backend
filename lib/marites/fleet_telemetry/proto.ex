defmodule Marites.FleetTelemetry.Payload do
  use Protobuf, syntax: :proto3

  field :vin,  1, type: :string
  field :txid, 4, type: :string
  field :data, 2, label: :repeated, type: Marites.FleetTelemetry.Datum
end

defmodule Marites.FleetTelemetry.Datum do
  use Protobuf, syntax: :proto3

  field :key,   1, type: Marites.FleetTelemetry.Field, enum: true
  field :value, 2, type: Marites.FleetTelemetry.Value
end

defmodule Marites.FleetTelemetry.Value do
  use Protobuf, syntax: :proto3

  oneof :value, 0

  field :string_value,   1, type: :string,   oneof: 0
  field :int_value,      2, type: :int64,    oneof: 0
  field :double_value,   3, type: :double,   oneof: 0
  field :bool_value,     4, type: :bool,     oneof: 0
  field :location_value, 5, type: Marites.FleetTelemetry.Location, oneof: 0
  field :float_value,    6, type: :float,    oneof: 0
end

defmodule Marites.FleetTelemetry.Location do
  use Protobuf, syntax: :proto3

  field :latitude,  1, type: :double
  field :longitude, 2, type: :double
end

defmodule Marites.FleetTelemetry.Field do
  use Protobuf, enum: true, syntax: :proto3

  field :Unknown,      0
  field :ChargeState, 12
  field :GearSelector, 60
  field :Location,    73
  field :Odometer,   129
  field :SentryMode, 167
  field :Soc,        182
  field :VehicleSpeed, 183
  field :ShiftState, 196
end
