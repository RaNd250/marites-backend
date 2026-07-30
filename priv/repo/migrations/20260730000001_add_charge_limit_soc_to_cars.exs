defmodule Marites.Repo.Migrations.AddChargeLimitSocToCars do
  use Ecto.Migration

  # Live charge-target % from Fleet Telemetry's ChargeLimitSoc field, used by
  # the Core "charging live notification" (time-to-limit ETA). Mirrors the
  # charge_state column: a single current-value scalar kept fresh by the FT
  # consumer, not a time series.
  def up do
    execute "ALTER TABLE cars ADD COLUMN IF NOT EXISTS charge_limit_soc integer"
  end

  def down do
    execute "ALTER TABLE cars DROP COLUMN IF EXISTS charge_limit_soc"
  end
end
