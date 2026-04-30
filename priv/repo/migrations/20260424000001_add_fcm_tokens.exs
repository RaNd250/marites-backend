defmodule Marites.Repo.Migrations.AddFcmTokens do
  use Ecto.Migration

  def change do
    create table(:fcm_tokens) do
      add :id, :bigserial, primary_key: true
      add :device_id, :string, null: false
      add :token, :string, null: false

      timestamps()
    end

    create unique_index(:fcm_tokens, [:device_id])
  end
end
