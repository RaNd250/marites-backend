defmodule Marites.Repo.Migrations.AddGuiPressureUnitsToCars do
  use Ecto.Migration

  # Mirrors Tesla's gui_settings.gui_pressure_units ("psi" | "bar") the same
  # way gui_distance_units/gui_temperature_units already are (see
  # 20260612000002_add_gui_units_to_cars.exs + GuiSettingsSync). Drives the
  # web TPMS widget's per-vehicle unit instead of the app-wide metric/imperial
  # toggle.
  def change do
    alter table(:cars) do
      add_if_not_exists :gui_pressure_units, :string, null: true
    end
  end
end
