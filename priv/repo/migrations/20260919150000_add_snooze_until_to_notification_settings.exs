defmodule Marites.Repo.Migrations.AddSnoozeUntilToNotificationSettings do
  @moduledoc """
  Mirrors marites-api's own copy of this migration
  (20260919150000, `MaritesAPI.Repo.Migrations.AddSnoozeUntilToNotificationSettings`)
  -- see that file for the full rationale. marites-api is what actually reads
  and writes `notification_settings` today and is the deploy pipeline this
  runs against for real; this copy just keeps marites-backend's own
  `mix ecto.migrate` a safe no-op on the same shared database.
  """
  use Ecto.Migration

  def up do
    alter table(:notification_settings) do
      add_if_not_exists :snooze_until, :utc_datetime
    end
  end

  def down do
    alter table(:notification_settings) do
      remove_if_exists :snooze_until, :utc_datetime
    end
  end
end
