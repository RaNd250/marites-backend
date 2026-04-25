defmodule TeslaMate.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email,              :string
    field :password,           :string, virtual: true
    field :password_hash,      :string
    field :admin,              :boolean, default: false
    field :active,             :boolean, default: true
    field :history_enabled,    :boolean, default: true
    field :notification_email, :string
    timestamps(updated_at: false)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: pw}} = cs) do
    put_change(cs, :password_hash, Bcrypt.hash_pwd_salt(pw))
  end

  defp put_password_hash(cs), do: cs
end
