defmodule Marites.Repo.Migrations.AddUserIdToFcmTokens do
  use Ecto.Migration

  def change do
    alter table(:fcm_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:fcm_tokens, [:user_id])
  end
end
