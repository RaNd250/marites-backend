defmodule Marites.Repo.Migrations.AddAppVersionToFcmTokens do
  @moduledoc """
  Client-reported app version ("0.1.146 (160)" style, versionName + versionCode
  or CFBundleShortVersionString + CFBundleVersion on iOS), sent optionally at
  FCM registration time -- same backward-compatible pattern as :locale
  (MaritesAPI.FCM.TokenStore.register/6): an older client that never sends it
  behaves exactly as before this column existed. Powers the /admin version
  breakdown the owner asked for (2026-09-15).
  """
  use Ecto.Migration

  def change do
    alter table(:fcm_tokens) do
      add :app_version, :string
    end
  end
end
