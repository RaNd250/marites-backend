defmodule TeslaMate.Repo.Migrations.AddSentryEvents do
  use Ecto.Migration

  def change do
    create table(:sentry_events) do
      add :id, :bigserial, primary_key: true
      add :car_id, references(:cars), null: false, on_delete: :delete_all
      add :activated_at, :utc_datetime, null: false
      add :deactivated_at, :utc_datetime, null: true
      add :duration_seconds, :integer, null: true
      add :start_lat, :float, null: true
      add :start_lng, :float, null: true
      add :address, :string, null: true

      timestamps()
    end

    create index(:sentry_events, [:car_id])
    create index(:sentry_events, [:activated_at])
  end
end
