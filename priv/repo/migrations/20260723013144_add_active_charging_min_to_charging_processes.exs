defmodule Marites.Repo.Migrations.AddActiveChargingMinToChargingProcesses do
  use Ecto.Migration

  # Additive companion to duration_min (which stays untouched -- it drives
  # per-minute billing in charge_live/cost.ex and must never be redefined).
  # duration_min is total PLUGGED-IN time (first to last sample of the
  # session). active_charging_min is our best estimate of time current was
  # actually flowing, computed from FT power/current sample gaps in
  # FleetTelemetry.Consumer (zero-order-hold between ACChargingPower/
  # DCChargingPower/ChargeAmps samples). Nullable: only FT-era sessions with
  # power/current samples get a value; SoC-derived (REST-detector) sessions
  # and historical rows predating this change are left NULL -- no backfill.
  def up do
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS active_charging_min integer"
  end

  def down do
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS active_charging_min"
  end
end
