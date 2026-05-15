defmodule Marites.FCM.TokenStore do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Marites.Repo

  schema "fcm_tokens" do
    field :device_id, :string
    field :token, :string
    field :user_id, :integer
    field :edition, :string, default: "core"
    timestamps()
  end

  def changeset(token_store, attrs) do
    token_store
    |> cast(attrs, [:device_id, :token, :user_id, :edition])
    |> validate_required([:device_id, :token, :user_id])
    |> validate_inclusion(:edition, ["core", "lite"])
  end

  def register(device_id, token, user_id, edition \\ "core") do
    result = Repo.insert(
      %__MODULE__{device_id: device_id, token: token, user_id: user_id, edition: edition},
      on_conflict: [set: [token: token, user_id: user_id, edition: edition, updated_at: DateTime.utc_now()]],
      conflict_target: :device_id
    )
    Phoenix.PubSub.broadcast(Marites.PubSub, "fcm_tokens/changed/#{user_id}", {:fcm_tokens_changed, user_id})
    result
  end

  def unregister(device_id) do
    user_id = Repo.one(from t in __MODULE__, where: t.device_id == ^device_id, select: t.user_id)
    from(t in __MODULE__, where: t.device_id == ^device_id) |> Repo.delete_all()
    if user_id, do: Phoenix.PubSub.broadcast(Marites.PubSub, "fcm_tokens/changed/#{user_id}", {:fcm_tokens_changed, user_id})
    :ok
  end

  def tokens_for_user(user_id, edition \\ nil) do
    base = from t in __MODULE__, where: t.user_id == ^user_id, select: t.token
    query = if edition, do: where(base, [t], t.edition == ^edition), else: base
    Repo.all(query)
  end

  def any_core_token?(user_id) do
    Repo.exists?(from t in __MODULE__, where: t.user_id == ^user_id and t.edition == "core")
  end
end
