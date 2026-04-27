defmodule TeslaMate.Repo.Migrations.CreateSentrySchedules do
  use Ecto.Migration

  def change do
    create table(:sentry_schedules) do
      add :user_id,    references(:users, on_delete: :delete_all), null: false
      add :car_id,     references(:cars,  on_delete: :delete_all), null: false
      add :enabled,    :boolean, default: true,  null: false
      add :on_hour,    :integer, null: false
      add :on_minute,  :integer, null: false
      add :off_hour,   :integer, null: false
      add :off_minute, :integer, null: false
      timestamps()
    end

    create unique_index(:sentry_schedules, [:car_id])
    create index(:sentry_schedules, [:user_id])
  end
end
