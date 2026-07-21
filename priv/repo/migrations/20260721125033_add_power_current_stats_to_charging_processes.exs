defmodule Marites.Repo.Migrations.AddPowerCurrentStatsToChargingProcesses do
  use Ecto.Migration

  # Real per-session power (kW) and current (A) from Fleet Telemetry's
  # ACChargingPower/DCChargingPower/ChargeAmps fields, replacing the dead
  # REST-era per-sample `charges.charger_power`/`charger_actual_current`
  # columns (unpopulated by the FT pipeline since the AGPL split).
  def up do
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS avg_power_kw numeric"
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS min_power_kw numeric"
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS max_power_kw numeric"
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS avg_current_a numeric"
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS min_current_a numeric"
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS max_current_a numeric"
  end

  def down do
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS avg_power_kw"
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS min_power_kw"
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS max_power_kw"
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS avg_current_a"
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS min_current_a"
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS max_current_a"
  end
end
