defmodule Marites.Repo.Migrations.AddAlertPrefs do
  use Ecto.Migration

  def up do
    alter table(:car_access) do
      add :alerts_enabled, :boolean, default: true, null: false
    end

    alter table(:users) do
      add :selected_car_changed_at, :utc_datetime
    end

    flush()

    # Option B seed: preserve prior behavior. Disable Core alerts only for shared
    # rows where the user neither owns the car nor has it as their selected car.
    execute("""
    UPDATE car_access ca
    SET alerts_enabled = false
    FROM cars c, users u
    WHERE ca.car_id = c.id
      AND ca.user_id = u.id
      AND c.user_id <> ca.user_id
      AND (u.selected_car_id IS DISTINCT FROM ca.car_id)
    """)
  end

  def down do
    alter table(:car_access) do
      remove :alerts_enabled
    end

    alter table(:users) do
      remove :selected_car_changed_at
    end
  end
end
