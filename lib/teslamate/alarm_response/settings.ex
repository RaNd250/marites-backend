defmodule TeslaMate.AlarmResponse.Settings do
  use Ecto.Schema
  import Ecto.Changeset
  alias TeslaMate.Repo

  @primary_key {:user_id, :integer, autogenerate: false}
  schema "alarm_response_settings" do
    field :honk_on_alarm,  :boolean, default: false
    field :flash_on_alarm, :boolean, default: false
    timestamps()
  end

  def get(user_id) do
    case Repo.get(__MODULE__, user_id) do
      nil -> %{honk_on_alarm: false, flash_on_alarm: false}
      row -> %{honk_on_alarm: row.honk_on_alarm, flash_on_alarm: row.flash_on_alarm}
    end
  end

  def upsert(user_id, attrs) do
    %__MODULE__{user_id: user_id}
    |> cast(attrs, [:honk_on_alarm, :flash_on_alarm])
    |> Repo.insert(
      on_conflict: {:replace, [:honk_on_alarm, :flash_on_alarm, :updated_at]},
      conflict_target: :user_id
    )
  end
end
