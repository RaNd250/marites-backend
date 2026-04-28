defmodule TeslaMate.Repo.Migrations.AddDayOfWeekToSentrySchedules do
  use Ecto.Migration

  def up do
    alter table(:sentry_schedules) do
      add :day_of_week, :integer
    end

    # Seed days 1–6 from each existing single-day row
    execute """
      INSERT INTO sentry_schedules (user_id, car_id, enabled, on_hour, on_minute, off_hour, off_minute, day_of_week, inserted_at, updated_at)
      SELECT s.user_id, s.car_id, s.enabled, s.on_hour, s.on_minute, s.off_hour, s.off_minute, d.day, now(), now()
      FROM sentry_schedules s
      CROSS JOIN (SELECT generate_series(1, 6) AS day) d
      WHERE s.day_of_week IS NULL
    """

    execute "UPDATE sentry_schedules SET day_of_week = 0 WHERE day_of_week IS NULL"

    alter table(:sentry_schedules) do
      modify :day_of_week, :integer, null: false
    end

    create unique_index(:sentry_schedules, [:car_id, :user_id, :day_of_week])
  end

  def down do
    drop_if_exists unique_index(:sentry_schedules, [:car_id, :user_id, :day_of_week])
    execute "DELETE FROM sentry_schedules WHERE day_of_week != 0"

    alter table(:sentry_schedules) do
      modify :day_of_week, :integer, null: true
    end

    execute "UPDATE sentry_schedules SET day_of_week = NULL"

    alter table(:sentry_schedules) do
      remove :day_of_week
    end
  end
end
