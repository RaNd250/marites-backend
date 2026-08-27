defmodule Marites.Repo.Migrations.AddDataRetentionDaysToUsers do
  use Ecto.Migration
  # Per-user raw location (Position) history retention window, in days.
  # 0 = keep forever (default) — preserves existing behavior for all current
  # users; this is an opt-in setting, never a silent retroactive deletion
  # policy. Allowed non-zero values are enforced application-side
  # (Accounts.update_settings/2): 30 / 90 / 180 / 365.
  def change do
    alter table(:users) do
      add_if_not_exists :data_retention_days, :integer, null: false, default: 0
    end
  end
end
