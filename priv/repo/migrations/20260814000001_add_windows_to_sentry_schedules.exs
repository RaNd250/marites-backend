defmodule Marites.Repo.Migrations.AddWindowsToSentrySchedules do
  use Ecto.Migration

  # Multi-window schedule (up to 4 on/off pairs per day, was 1). Old flat
  # on_hour/on_minute/off_hour/off_minute columns are kept in place (not
  # dropped) for rollback safety and because they're cheap to leave — the
  # app code no longer reads or writes them after this change.
  def up do
    alter table(:sentry_schedules) do
      add :windows, :map
    end

    execute """
      UPDATE sentry_schedules
      SET windows = jsonb_build_array(
        jsonb_build_object(
          'on_hour', on_hour, 'on_minute', on_minute,
          'off_hour', off_hour, 'off_minute', off_minute
        )
      )
      WHERE windows IS NULL
    """

    execute "ALTER TABLE sentry_schedules ALTER COLUMN windows SET DEFAULT '[]'::jsonb"
    execute "UPDATE sentry_schedules SET windows = '[]'::jsonb WHERE windows IS NULL"
  end

  def down do
    alter table(:sentry_schedules) do
      remove :windows
    end
  end
end
