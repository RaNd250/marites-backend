defmodule Marites.Repo.Migrations.AddNotificationSettings do
  use Ecto.Migration

  def change do
    create table(:notification_settings) do
      add :id, :bigserial, primary_key: true
      add :event_type, :string, null: false, values: ["sentry_activated", "sentry_deactivated", "charge_complete", "charge_started", "battery_low"]
      add :enabled, :boolean, default: true, null: false
      add :threshold, :integer, null: true

      timestamps()
    end

    create unique_index(:notification_settings, [:event_type])
  end
end
