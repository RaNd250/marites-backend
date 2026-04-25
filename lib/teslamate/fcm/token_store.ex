defmodule TeslaMate.FCM.TokenStore do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TeslaMate.Repo

  schema "fcm_tokens" do
    field :device_id, :string
    field :token, :string
    timestamps()
  end

  def changeset(token_store, attrs) do
    token_store
    |> cast(attrs, [:device_id, :token])
    |> validate_required([:device_id, :token])
  end

  def register(device_id, token) do
    Repo.insert(
      %__MODULE__{device_id: device_id, token: token},
      on_conflict: [set: [token: token, updated_at: DateTime.utc_now()]],
      conflict_target: :device_id
    )
  end

  def unregister(device_id) do
    from(t in __MODULE__, where: t.device_id == ^device_id)
    |> Repo.delete_all()
  end

  def all_tokens do
    Repo.all(from t in __MODULE__, select: t.token)
  end
end
