defmodule Marites.Repo.Migrations.AddGuiUnitsToCars do
  use Ecto.Migration
  def change do
    alter table(:cars) do
      add_if_not_exists :gui_distance_units, :string, null: true
      add_if_not_exists :gui_temperature_units, :string, null: true
      add_if_not_exists :gui_24_hour_time, :boolean, null: true
    end
  end
end
