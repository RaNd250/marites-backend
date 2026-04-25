defmodule TeslaMate.Accounts.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "refresh_tokens" do
    field :user_id,    :id
    field :token_hash, :string
    field :expires_at, :utc_datetime
    timestamps(updated_at: false)
  end

  def changeset(rt, attrs) do
    rt
    |> cast(attrs, [:user_id, :token_hash, :expires_at])
    |> validate_required([:user_id, :token_hash, :expires_at])
    |> unique_constraint(:token_hash)
  end
end
