defmodule Marites.Repo.Migrations.AddEditionToFcmTokens do
  use Ecto.Migration

  def change do
    alter table(:fcm_tokens) do
      add :edition, :string, default: "core", null: false
    end

    create index(:fcm_tokens, [:user_id, :edition])
  end
end
