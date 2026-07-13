defmodule Marites.Repo.Migrations.AddPositionsCarIdDateIndex do
  use Ecto.Migration

  # Plain composite index for the common (car_id, date-range) scans — stats
  # battery_health and the API consumer's position reads. The existing
  # car_id+date index is partial (WHERE ideal_battery_range_km IS NOT NULL) and
  # fleet-telemetry-written rows do not set that column.
  def up do
    execute "CREATE INDEX IF NOT EXISTS positions_car_id_date_index ON positions (car_id, date)"
  end

  def down do
    execute "DROP INDEX IF EXISTS positions_car_id_date_index"
  end
end
