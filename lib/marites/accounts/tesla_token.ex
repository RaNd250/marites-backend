defmodule Marites.Accounts.TeslaToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tesla_tokens" do
    field :user_id,                  :id
    field :encrypted_refresh_token,  Marites.Vault.Encrypted.Binary
    field :access_token,             Marites.Vault.Encrypted.Binary
    field :token_expires_at,         :utc_datetime
    timestamps()
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:user_id, :encrypted_refresh_token, :access_token, :token_expires_at])
    |> validate_required([:user_id])
    |> unique_constraint(:user_id)
  end
end
