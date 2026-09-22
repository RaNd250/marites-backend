defmodule Marites.Repo.Migrations.CreateCarAccess do
  use Ecto.Migration

  def change do
    create table(:car_access, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :car_id,  references(:cars,  on_delete: :delete_all), null: false
      add :inserted_at, :naive_datetime, null: false
    end

    execute "ALTER TABLE car_access ADD PRIMARY KEY (user_id, car_id)", ""

    create index(:car_access, [:user_id])
    create index(:car_access, [:car_id])

    # Seed: owners get access to their own cars
    execute """
    INSERT INTO car_access (user_id, car_id, inserted_at)
    SELECT user_id, id, NOW()
    FROM cars
    WHERE user_id IS NOT NULL
    ON CONFLICT DO NOTHING
    """, ""

    # Seed: user_id=6 (papakigr@hotmail.com) gets access to car 1 and car 2.
    # Guarded so the migration also runs on databases without the prod rows.
    execute """
    INSERT INTO car_access (user_id, car_id, inserted_at)
    SELECT u.id, c.id, NOW()
    FROM users u
    CROSS JOIN cars c
    WHERE u.id = 6 AND c.id IN (1, 2)
    ON CONFLICT DO NOTHING
    """, ""
  end
end
