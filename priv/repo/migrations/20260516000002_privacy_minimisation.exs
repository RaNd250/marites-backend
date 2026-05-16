defmodule Marites.Repo.Migrations.PrivacyMinimisation do
  use Ecto.Migration

  def up do
    # Drop cosmetic car fields — never surfaced in any API or UI
    alter table(:cars) do
      remove :exterior_color, :string
      remove :wheel_type, :string
      remove :spoiler_type, :string
    end

    # Drop notification_email — always equal to email in OAuth flow, not configurable
    alter table(:users) do
      remove :notification_email, :string
    end

    # Drop stored address from sentry_events — lat/lng is sufficient;
    # address can be derived on-demand client-side if needed
    alter table(:sentry_events) do
      remove :address, :string
    end

    # Encrypt access_token at rest (existing short-lived tokens cleared;
    # app will re-fetch via refresh token on next launch)
    execute "UPDATE tesla_tokens SET access_token = NULL"
    execute "ALTER TABLE tesla_tokens DROP COLUMN access_token"
    execute "ALTER TABLE tesla_tokens ADD COLUMN access_token bytea"
  end

  def down do
    alter table(:cars) do
      add :exterior_color, :string
      add :wheel_type, :string
      add :spoiler_type, :string
    end

    alter table(:users) do
      add :notification_email, :string
    end

    alter table(:sentry_events) do
      add :address, :string
    end

    execute "ALTER TABLE tesla_tokens DROP COLUMN access_token"
    execute "ALTER TABLE tesla_tokens ADD COLUMN access_token varchar(255)"
  end
end
