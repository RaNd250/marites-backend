defmodule Marites.Repo.Migrations.AddReauthRequiredAtToTeslaTokens do
  use Ecto.Migration
  # Set (to the detection time) when MaritesAPI.Api's :refresh_auth handler
  # sees Tesla report the user revoked OAuth consent ("login_required" / User
  # consent revoked) -- persists what used to be an in-memory-only signal, so
  # RegistrationPoller/Registrar and GuiSettingsSync can skip a car whose
  # owner's token is known-dead instead of retrying it forever every 30 min.
  # Cleared back to nil on the next successful token refresh or sign_in.
  def change do
    alter table(:tesla_tokens) do
      add_if_not_exists :reauth_required_at, :utc_datetime, null: true, default: nil
    end
  end
end
