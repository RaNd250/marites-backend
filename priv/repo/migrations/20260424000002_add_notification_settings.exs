defmodule TeslaMate.Repo.Migrations.AddNotificationSettings do
  use Ecto.Migration

  def change do
    create table(:notification_settings) do
      add :event_type, :string, null: false
      add :enabled, :boolean, default: true, null: false
      add :threshold, :integer, null: true

      timestamps()
    end

    create unique_index(:notification_settings, [:event_type])
  end
end
