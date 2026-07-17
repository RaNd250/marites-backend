defmodule Marites.Repo.Migrations.AddCompletionNotifiedToChargingProcesses do
  use Ecto.Migration

  # Stamped by marites-api's ChargingDetector once the "charging complete"
  # notification for a session was dispatched (or deliberately skipped for
  # old/backfilled sessions), so a session is never announced twice.
  def up do
    execute "ALTER TABLE charging_processes ADD COLUMN IF NOT EXISTS completion_notified_at timestamptz"
  end

  def down do
    execute "ALTER TABLE charging_processes DROP COLUMN IF EXISTS completion_notified_at"
  end
end
