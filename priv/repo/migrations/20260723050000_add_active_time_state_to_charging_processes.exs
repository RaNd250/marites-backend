defmodule Marites.Repo.Migrations.AddActiveTimeStateToChargingProcesses do
  use Ecto.Migration

  # Bug fix (2026-07-23): active_charging_min's zero-order-hold accumulator
  # (last_sample_at/active_now/active_seconds -- see FleetTelemetry.Consumer)
  # lived ONLY in the Consumer GenServer's in-memory `charging` map. Every
  # marites-api restart (i.e. every deploy) calls recover_open_charging/0,
  # which rebuilt {cp_id, start_soc, start_date} for still-open sessions but
  # NOT this bookkeeping -- silently resetting the active-time clock to zero
  # for any session that happened to be open across the restart. Prod
  # incident: session id 703 (2026-07-23 01:07-03:08, steady ~32A the whole
  # time) reported active_charging_min: 9 instead of ~60+ because marites-api
  # restarted mid-session to deploy this very feature.
  #
  # These 3 columns are internal bookkeeping only -- never exposed via the
  # charges API (format_charge/2 in charges_controller.ex is an explicit
  # whitelist) -- persisted on every power/current sample so
  # recover_open_charging/0 can rehydrate the accumulator exactly as it was
  # in memory before the restart.
  def up do
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS active_time_seconds double precision"
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS active_last_sample_at timestamptz"
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS active_last_sample_active boolean"
  end

  def down do
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS active_time_seconds"
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS active_last_sample_at"
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS active_last_sample_active"
  end
end
