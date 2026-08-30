defmodule Marites.Repo.Migrations.AddVkReminderColumnsToUsers do
  use Ecto.Migration
  # Support columns for the *separate* virtual-key-not-paired reminder
  # (MaritesAPI.VirtualKeyReminderPoller, marites-api) -- deliberately NOT
  # sharing last_pairing_reminder_sent_at (20260830130000) with
  # PairingReminderPoller: that poller explicitly excludes the
  # virtual_key_not_paired bucket (see its moduledoc), so sharing a throttle
  # column would let one poller's stamp silently suppress the other.
  #
  # - last_vk_reminder_sent_at: once-per-day throttle, same semantics as
  #   last_pairing_reminder_sent_at (left nil when skipped for no FCM
  #   token, so the user stays eligible rather than losing their one shot).
  # - vk_reminder_snooze_until: set when the user taps "Later"/"Dismiss" on
  #   the in-app VK setup dialog (POST /api/v1/vk_reminder/snooze); mirrors
  #   users.sentry_snooze_until's shape (a future UTC timestamp, nil/past =
  #   not snoozed) but is a distinct column since the two snoozes are
  #   unrelated concerns.
  def change do
    alter table(:users) do
      add_if_not_exists :last_vk_reminder_sent_at, :utc_datetime, null: true, default: nil
      add_if_not_exists :vk_reminder_snooze_until, :utc_datetime, null: true, default: nil
    end
  end
end
