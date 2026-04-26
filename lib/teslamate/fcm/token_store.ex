defmodule TeslaMate.FCM.TokenStore do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TeslaMate.Repo

  schema "fcm_tokens" do
    field :device_id, :string
    field :token, :string
    field :user_id, :integer
    timestamps()
  end

  def changeset(token_store, attrs) do
    token_store
    |> cast(attrs, [:device_id, :token, :user_id])
    |> validate_required([:device_id, :token, :user_id])
  end

  def register(device_id, token, user_id) do
    Repo.insert(
      %__MODULE__{device_id: device_id, token: token, user_id: user_id},
      on_conflict: [set: [token: token, user_id: user_id, updated_at: DateTime.utc_now()]],
      conflict_target: :device_id
    )
  end

  def unregister(device_id) do
    from(t in __MODULE__, where: t.device_id == ^device_id)
    |> Repo.delete_all()
  end

  def tokens_for_user(user_id) do
    Repo.all(from t in __MODULE__, where: t.user_id == ^user_id, select: t.token)
  end
end
