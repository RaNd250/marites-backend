defmodule Marites.Auth do
  use Ecto.Schema
  import Ecto.Changeset

  # Embedded schema for the sign-in form — Tesla token entry is forwarded to marites-api.
  embedded_schema do
    field :access, :string
    field :refresh, :string
  end

  def change_tokens(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:access, :refresh])
    |> validate_required([:access, :refresh])
  end

  # Token sign-in is now handled by marites-api; this delegate is a no-op for the engine UI.
  def sign_in(_tokens), do: :ok
end
