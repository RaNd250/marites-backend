defmodule Marites.Repo.Migrations.DropSingleColumnNotificationSettingsIndex do
  use Ecto.Migration

  def change do
    drop_if_exists unique_index(:notification_settings, [:event_type])
  end
end
