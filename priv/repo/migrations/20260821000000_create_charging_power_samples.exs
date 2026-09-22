defmodule Marites.Repo.Migrations.CreateChargingPowerSamples do
  use Ecto.Migration

  # FT-era charging curve data. The legacy `charges` table (REST-era) stores
  # one row per Tesla API poll with an integer-watts `charger_power` column;
  # reusing it for FT samples would truncate the float kW values FT streams
  # (ACChargingPower/DCChargingPower) and mix two different sampling
  # semantics in one table. This is a separate, purpose-built time series so
  # the /charges/:id/samples endpoint can plot a real power(t) curve.
  def change do
    create table(:charging_power_samples) do
      add :charging_process_id, references(:charging_processes, on_delete: :delete_all), null: false
      add :date, :utc_datetime_usec, null: false
      add :power_kw, :float
      add :current_a, :float
      add :soc, :integer
    end

    create index(:charging_power_samples, [:charging_process_id, :date])
  end
end
