defmodule Marites.Vault do
  @moduledoc """
  Cloak vault for the engine. Mirrors MaritesAPI.Vault exactly (same cipher,
  same key-derivation), so ciphertext written by one app's Vault decrypts
  fine through the other's — both are configured from the same ENCRYPTION_KEY
  env var (see config/runtime.exs and .env on the deploy host). This lets
  positions.latitude/longitude — inserted by marites-api's Fleet Telemetry
  consumer, but read here (Marites.Terrain elevation backfill, any legacy
  engine read path) — decrypt transparently on both sides.

  Historical note: this module previously existed to encrypt Tesla API
  tokens (see git history / upstream TeslaMate), before that responsibility
  moved to marites-api during the AGPL compliance split (commit
  83c10f2e). It was deleted then and is restored here now, scoped to
  Position coordinates only — the engine no longer stores or reads tokens.
  """
  use Cloak.Vault,
    otp_app: :marites

  require Logger

  # With AES.GCM, 12-byte IV length is necessary for interoperability reasons.
  # See https://github.com/danielberkompas/cloak/issues/93
  @iv_length 12

  def default_cipher(key) do
    {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: key, iv_length: @iv_length}
  end

  @impl GenServer
  def init(config) do
    encryption_key =
      case get_encryption_key_from_config() do
        {:ok, key} ->
          key

        :error ->
          raise """
          No ENCRYPTION_KEY found. Set the ENCRYPTION_KEY environment variable to the
          same value used by marites-api.
          """
      end

    config =
      Keyword.put(config, :ciphers,
        default: default_cipher(:crypto.hash(:sha256, encryption_key))
      )

    {:ok, config}
  end

  defp get_encryption_key_from_config do
    Application.get_env(:marites, Marites.Vault)
    |> Access.fetch!(:key)
    |> case do
      key when is_binary(key) and byte_size(key) > 0 -> {:ok, key}
      _ -> :error
    end
  end
end
