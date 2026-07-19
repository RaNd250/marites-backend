defmodule Marites.Repo.Migrations.AddFsdTrackingColumns do
  use Ecto.Migration

  # FSD usage tracking from Fleet Telemetry's SelfDrivingMilesSinceReset — a
  # LIFETIME cumulative counter of miles driven on FSD (HW4 + firmware
  # 2025.44.25.5+ only; absent on other vehicles).
  #
  # positions.self_driving_miles_since_reset stores the raw counter per sample
  # (miles, as streamed); drives.fsd_km stores the per-drive DELTA converted to
  # km, computed by marites-api's Consumer at drive close. Both nullable: cars
  # without the field simply never populate them (NULL means "not supported",
  # never 0).
  def up do
    execute "ALTER TABLE positions ADD COLUMN IF NOT EXISTS self_driving_miles_since_reset double precision"
    execute "ALTER TABLE drives ADD COLUMN IF NOT EXISTS fsd_km double precision"
  end

  def down do
    execute "ALTER TABLE positions DROP COLUMN IF EXISTS self_driving_miles_since_reset"
    execute "ALTER TABLE drives DROP COLUMN IF EXISTS fsd_km"
  end
end
