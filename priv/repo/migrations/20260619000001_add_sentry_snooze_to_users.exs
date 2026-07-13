defmodule Marites.Repo.Migrations.AddSentrySnoozeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :sentry_snooze_until, :utc_datetime
    end
  end
end
