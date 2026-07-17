defmodule Marites.Repo.Migrations.AddDriverTempSettingToDrives do
  use Ecto.Migration

  # AC target temperature (climate_state.driver_temp_setting, Celsius) captured
  # by marites-api once at drive start via a single vehicle_data REST call
  # (see MaritesAPI.FleetTelemetry.AcSetpoint). Nullable: signed-out users,
  # offline fetches and pre-feature drives simply have no value.
  def up do
    execute "ALTER TABLE drives ADD COLUMN IF NOT EXISTS driver_temp_setting double precision"
  end

  def down do
    execute "ALTER TABLE drives DROP COLUMN IF EXISTS driver_temp_setting"
  end
end
