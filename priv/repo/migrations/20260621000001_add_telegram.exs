defmodule Marites.Repo.Migrations.AddTelegram do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :push_enabled, :boolean, default: true, null: false
    end

    create table(:telegram_links) do
      add :user_id, :integer, null: false
      add :chat_id, :bigint, null: false
      add :enabled, :boolean, default: true, null: false
      add :linked_at, :utc_datetime
      timestamps()
    end

    create unique_index(:telegram_links, [:user_id])

    create table(:telegram_link_tokens) do
      add :token_hash, :string, null: false
      add :user_id, :integer, null: false
      add :expires_at, :utc_datetime, null: false
      add :consumed_at, :utc_datetime
      timestamps(updated_at: false)
    end

    create unique_index(:telegram_link_tokens, [:token_hash])
  end
end
