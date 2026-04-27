defmodule TeslaMate.Repo.Migrations.CreateAlarmResponseSettings do
  use Ecto.Migration

  def change do
    create table(:alarm_response_settings, primary_key: false) do
      add :user_id,        :integer, primary_key: true, null: false
      add :honk_on_alarm,  :boolean, null: false, default: false
      add :flash_on_alarm, :boolean, null: false, default: false
      timestamps()
    end
  end
end
