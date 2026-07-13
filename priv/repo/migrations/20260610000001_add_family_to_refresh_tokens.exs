defmodule Marites.Repo.Migrations.AddFamilyToRefreshTokens do
  use Ecto.Migration

  # Raw IF NOT EXISTS SQL: marites-api's ensure_schema/0 adds the same columns
  # at boot (the engine and API deploy jobs run in parallel), so this migration
  # must be a no-op when the API got there first.
  def up do
    execute "ALTER TABLE refresh_tokens ADD COLUMN IF NOT EXISTS family_id uuid"
    execute "ALTER TABLE refresh_tokens ADD COLUMN IF NOT EXISTS superseded_at timestamp(0)"
    execute "CREATE INDEX IF NOT EXISTS refresh_tokens_family_id_index ON refresh_tokens (family_id)"
  end

  def down do
    execute "DROP INDEX IF EXISTS refresh_tokens_family_id_index"
    execute "ALTER TABLE refresh_tokens DROP COLUMN IF EXISTS superseded_at"
    execute "ALTER TABLE refresh_tokens DROP COLUMN IF EXISTS family_id"
  end
end
