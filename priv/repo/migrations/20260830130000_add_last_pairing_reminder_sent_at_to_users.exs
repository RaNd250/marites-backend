defmodule Marites.Repo.Migrations.AddLastPairingReminderSentAtToUsers do
  use Ecto.Migration
  # Throttle column for MaritesAPI.PairingReminderPoller (marites-api): set
  # to the send time whenever a daily "finish pairing your Tesla" FCM
  # reminder actually goes out, so the poller can skip a user it already
  # nagged today (once-per-day cap) instead of relying on an in-memory-only
  # timestamp that resets on every deploy -- same rationale as
  # reauth_required_at (20260828120000) and users.last_lite_nag_at.
  # Left nil when a candidate user has no FCM token on file (poller skips
  # silently and does NOT stamp this, so they become eligible again as soon
  # as a token registers rather than being nagged only once ever).
  def change do
    alter table(:users) do
      add_if_not_exists :last_pairing_reminder_sent_at, :utc_datetime, null: true, default: nil
    end
  end
end
