defmodule Marites.Repo.Migrations.AddPaintWheelToCars do
  use Ecto.Migration

  # Raw Tesla API vehicle_config values (e.g. "PearlWhite", "UberTurbine21Black"),
  # kept fresh by GuiSettingsSync's existing 30-minute online-car poll (same
  # get_vehicle_with_state call already made for gui_settings -- no extra API
  # load). Used to build a real per-user Tesla compositor image URL
  # (static-assets.tesla.com) for the dashboard car photo, replacing the
  # generic model-silhouette icon.
  def up do
    execute "ALTER TABLE cars ADD COLUMN IF NOT EXISTS exterior_color varchar(255)"
    execute "ALTER TABLE cars ADD COLUMN IF NOT EXISTS wheel_type varchar(255)"
  end

  def down do
    execute "ALTER TABLE cars DROP COLUMN IF EXISTS exterior_color"
    execute "ALTER TABLE cars DROP COLUMN IF EXISTS wheel_type"
  end
end
