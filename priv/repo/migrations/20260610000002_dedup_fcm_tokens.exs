defmodule Marites.Repo.Migrations.DedupFcmTokens do
  use Ecto.Migration

  # fcm_tokens accumulated duplicate rows per token: the same FCM token
  # re-registered under a fresh device_id (reinstall / re-login) and the
  # device_id-keyed upsert never cleaned the old rows. One-time dedup keeping
  # the most recently updated row per token, then enforce uniqueness; the API's
  # TokenStore.register/4 now clears stale same-token rows before upserting.
  def up do
    execute """
    DELETE FROM fcm_tokens a USING fcm_tokens b
    WHERE a.token = b.token
      AND (a.updated_at < b.updated_at OR (a.updated_at = b.updated_at AND a.id < b.id))
    """

    execute "CREATE UNIQUE INDEX IF NOT EXISTS fcm_tokens_token_index ON fcm_tokens (token)"
  end

  def down do
    execute "DROP INDEX IF EXISTS fcm_tokens_token_index"
  end
end
