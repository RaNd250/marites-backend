defmodule Marites.Repo.Migrations.EncryptApiTokens do
  use Ecto.Migration

  # The original TeslaMate migration re-encrypted existing plaintext tokens via
  # Marites.Vault (Cloak) and emitted a generated ENCRYPTION_KEY. The AGPL
  # service split removed Vault and the cloak deps from the engine, and every
  # database that needed the data step has this migration recorded already.
  # Fresh databases have no token rows, so only the DDL remains.
  def change do
    alter table(:tokens) do
      add :encrypted_refresh, :binary
      add :encrypted_access, :binary
    end

    alter table(:tokens) do
      remove :access
      remove :refresh
    end

    rename table(:tokens), :encrypted_access, to: :access
    rename table(:tokens), :encrypted_refresh, to: :refresh
  end
end
