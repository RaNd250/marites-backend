defmodule TeslaMate.Notifications.Settings do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TeslaMate.Repo

  schema "notification_settings" do
    field :event_type, :string
    field :enabled, :boolean, default: true
    field :threshold, :integer
    timestamps()
  end

  @event_types ~w(sentry_activated sentry_deactivated charge_complete charge_started battery_low)

  def get_all do
    rows =
      Repo.all(__MODULE__)
      |> Enum.into(%{}, &{&1.event_type, %{enabled: &1.enabled, threshold: &1.threshold}})

    Enum.into(@event_types, %{}, fn et ->
      {et, Map.get(rows, et, %{enabled: true, threshold: nil})}
    end)
  end

  def update(event_type, attrs) do
    %__MODULE__{event_type: event_type}
    |> cast(attrs, [:enabled, :threshold])
    |> put_change(:event_type, event_type)
    |> validate_required([:event_type])
    |> Repo.insert(
      on_conflict: {:replace, [:enabled, :threshold, :updated_at]},
      conflict_target: :event_type
    )
  end

  def enabled?(event_type) do
    from(ns in __MODULE__, where: ns.event_type == ^event_type, select: ns.enabled)
    |> Repo.one()
    |> case do
      nil -> true
      val -> val
    end
  end
end
