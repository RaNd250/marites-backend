defmodule Marites.Repo.Migrations.AddEditionToRefreshTokens do
  use Ecto.Migration

  # "core" | "lite" | "web" | nil (nil = legacy row minted before this column
  # existed; treated as unknown, never matches an edition-specific check).
  def up do
    execute "ALTER TABLE refresh_tokens ADD COLUMN IF NOT EXISTS edition varchar(10)"
    execute "CREATE INDEX IF NOT EXISTS refresh_tokens_user_edition_index ON refresh_tokens (user_id, edition) WHERE superseded_at IS NULL"
  end

  def down do
    execute "DROP INDEX IF EXISTS refresh_tokens_user_edition_index"
    execute "ALTER TABLE refresh_tokens DROP COLUMN IF EXISTS edition"
  end
end
