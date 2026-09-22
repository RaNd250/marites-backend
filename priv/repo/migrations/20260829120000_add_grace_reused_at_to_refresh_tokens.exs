defmodule Marites.Repo.Migrations.AddGraceReusedAtToRefreshTokens do
  use Ecto.Migration
  # Reuse-race grace window (see auth_controller.ex do_refresh/2): a refresh
  # token replayed within a few seconds of its own supersession is treated as
  # the losing side of a client-side double-fire, not theft, and is allowed
  # exactly one graceful re-rotation. This column marks that it has already
  # happened so a genuine attacker can't keep replaying inside the window to
  # dodge detection.
  #
  # Raw IF NOT EXISTS SQL: marites-api's ensure_schema/0 adds the same column
  # at boot (the engine and API deploy jobs run in parallel), so this
  # migration must be a no-op when the API got there first.
  def up do
    execute "ALTER TABLE refresh_tokens ADD COLUMN IF NOT EXISTS grace_reused_at timestamp(0)"
  end
  def down do
    execute "ALTER TABLE refresh_tokens DROP COLUMN IF EXISTS grace_reused_at"
  end
end
