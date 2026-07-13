defmodule Marites.Repo.Migrations.CreatePairingCodes do
  use Ecto.Migration

  def change do
    create table(:pairing_codes) do
      add :code_hash, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :expires_at, :utc_datetime, null: false
      add :used_at, :utc_datetime
      timestamps(updated_at: false)
    end

    create unique_index(:pairing_codes, [:code_hash])
    create index(:pairing_codes, [:user_id])
  end
end
