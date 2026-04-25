defmodule TeslaMate.Accounts.InviteCode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invite_codes" do
    field :code,       :string
    field :created_by, :id
    field :used_by,    :id
    field :used_at,    :utc_datetime
    timestamps(updated_at: false)
  end

  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:code, :created_by])
    |> validate_required([:code, :created_by])
    |> unique_constraint(:code)
  end
end
