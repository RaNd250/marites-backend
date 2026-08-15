defmodule Marites.Repo.Migrations.AddIpDeviceNameToRefreshTokens do
  use Ecto.Migration

  # Captured at token mint time so the "already signed in" conflict dialog
  # (Lite blocked while Core has a live session) can tell the user *where*
  # the other session is, instead of just that one exists. Both are
  # best-effort/nullable -- older rows and any insert path that doesn't pass
  # them stay NULL, no backfill. Lifetime is bounded by the refresh token
  # itself (deleted on logout, superseded on rotation, 30-day expiry), so
  # this doesn't create any new long-lived personal-data retention.
  def change do
    alter table(:refresh_tokens) do
      add :ip, :string
      add :device_name, :string
    end
  end
end
