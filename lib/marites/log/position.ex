defmodule Marites.Log.Position do
  use Ecto.Schema
  import Ecto.Changeset

  alias Marites.Log.{Car, Drive}

  schema "positions" do
    field :date, :utc_datetime_usec
    # Encrypted at rest (Cloak.Ecto, AES-256-GCM) — same mechanism marites-api
    # uses for TeslaToken. Stored as an encrypted :binary column; Ecto
    # transparently dumps/loads it, so struct access still yields a plain
    # %Decimal{} everywhere. read_after_writes: true KEPT (still needed,
    # for a different reason than before): Marites.Vault.Encrypted.Decimal
    # rounds to 6 decimal places in before_encrypt/1 to preserve the
    # precision the old plain numeric(8,6)/(9,6) columns enforced, but that
    # rounding only happens to the bytes written to disk — without
    # read_after_writes, Repo.insert would return the struct with the
    # caller's original unrounded in-memory value instead of reflecting
    # what's actually stored. See the migration that renamed the old
    # plaintext columns to *_plain before backfilling these.
    field :latitude, Marites.Vault.Encrypted.Decimal, read_after_writes: true
    field :longitude, Marites.Vault.Encrypted.Decimal, read_after_writes: true
    field :elevation, :integer

    field :speed, :integer
    field :power, :integer
    field :odometer, :float
    field :ideal_battery_range_km, :decimal, read_after_writes: true
    field :est_battery_range_km, :decimal, read_after_writes: true
    field :rated_battery_range_km, :decimal, read_after_writes: true
    field :battery_level, :integer
    field :usable_battery_level, :integer
    field :battery_heater, :boolean
    field :battery_heater_on, :boolean
    field :battery_heater_no_power, :boolean
    field :outside_temp, :decimal, read_after_writes: true
    field :inside_temp, :decimal, read_after_writes: true
    field :fan_status, :integer
    field :driver_temp_setting, :decimal, read_after_writes: true
    field :passenger_temp_setting, :decimal, read_after_writes: true
    field :is_climate_on, :boolean
    field :is_rear_defroster_on, :boolean
    field :is_front_defroster_on, :boolean
    field :tpms_pressure_fl, :decimal
    field :tpms_pressure_fr, :decimal
    field :tpms_pressure_rl, :decimal
    field :tpms_pressure_rr, :decimal

    belongs_to(:car, Car)
    belongs_to(:drive, Drive)
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [
      :car_id,
      :date,
      :latitude,
      :longitude,
      :elevation,
      :speed,
      :power,
      :odometer,
      :ideal_battery_range_km,
      :est_battery_range_km,
      :rated_battery_range_km,
      :battery_level,
      :usable_battery_level,
      :battery_heater_no_power,
      :battery_heater_on,
      :battery_heater,
      :inside_temp,
      :outside_temp,
      :fan_status,
      :driver_temp_setting,
      :passenger_temp_setting,
      :is_climate_on,
      :is_rear_defroster_on,
      :is_front_defroster_on,
      :tpms_pressure_fl,
      :tpms_pressure_fr,
      :tpms_pressure_rl,
      :tpms_pressure_rr
    ])
    |> validate_required([:car_id, :date, :latitude, :longitude])
    |> foreign_key_constraint(:car_id)
    |> foreign_key_constraint(:drive_id)
  end
end
