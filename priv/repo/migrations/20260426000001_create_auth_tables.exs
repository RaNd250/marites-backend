defmodule TeslaMate.Repo.Migrations.CreateAuthTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email,             :string,  null: false
      add :password_hash,     :string,  null: false
      add :admin,             :boolean, null: false, default: false
      add :active,            :boolean, null: false, default: true
      add :history_enabled,   :boolean, null: false, default: true
      add :notification_email, :string
      timestamps(updated_at: false)
    end

    create unique_index(:users, [:email])

    create table(:invite_codes) do
      add :code,       :string,  null: false
      add :created_by, references(:users, on_delete: :delete_all), null: false
      add :used_by,    references(:users, on_delete: :nilify_all)
      add :used_at,    :utc_datetime
      timestamps(updated_at: false)
    end

    create unique_index(:invite_codes, [:code])

    create table(:refresh_tokens) do
      add :user_id,    references(:users, on_delete: :delete_all), null: false
      add :token_hash, :string, null: false
      add :expires_at, :utc_datetime, null: false
      timestamps(updated_at: false)
    end

    create index(:refresh_tokens, [:user_id])
    create unique_index(:refresh_tokens, [:token_hash])

    create table(:tesla_tokens) do
      add :user_id,                  references(:users, on_delete: :delete_all), null: false
      add :encrypted_refresh_token,  :binary
      add :access_token,             :string
      add :token_expires_at,         :utc_datetime
      timestamps()
    end

    create unique_index(:tesla_tokens, [:user_id])

    create table(:push_subscriptions) do
      add :user_id,   references(:users, on_delete: :delete_all), null: false
      add :endpoint,  :text,   null: false
      add :p256dh_key, :text,  null: false
      add :auth_key,  :text,   null: false
      timestamps(updated_at: false)
    end

    create index(:push_subscriptions, [:user_id])
    create unique_index(:push_subscriptions, [:endpoint])
  end
end
