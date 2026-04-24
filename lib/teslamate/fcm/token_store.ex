defmodule TeslaMate.FCM.TokenStore do
  use Ecto.Schema
  import Ecto.Changeset
  alias TeslaMate.Repo

  schema "fcm_tokens" do
    field(:device_id, :string)
    field(:token, :string)

    timestamps()
  end

  def changeset(token_store, attrs) do
    token_store
    |> cast(attrs, [:device_id, :token])
    |> validate_required([:device_id, :token])
  end

  def register(device_id, token) do
    Repo.insert(
      %TokenStore{device_id: device_id, token: token},
      on_conflict: [set: [token: token, updated_at: DateTime.utc_now()]],
      conflict_target: :device_id
    )
  end

  def unregister(device_id) do
    Repo.delete_all(TokenStore, device_id: device_id)
  end

  def all_tokens() do
    Repo.all(TokenStore)
    |> Enum.map(& &1.token)
  end
end
