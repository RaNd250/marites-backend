defmodule TeslaMate.Notifications.Settings do
  use Ecto.Schema

  schema "notification_settings" do
    field(:event_type, :string)
    field(:enabled, :boolean, default: true)
    field(:threshold, :integer)

    index([:event_type], unique: true)
  end

  @event_types ["sentry_activated", "sentry_deactivated", "charge_complete", "charge_started", "battery_low"]

  def get_all do
    query =
      from(ns in __MODULE__,
        select: {ns.event_type, %{enabled: ns.enabled, threshold: ns.threshold}},
        order_by: [asc: ns.event_type]
      )

    Repo.all(query)
    |> Enum.into(%{}, fn {event_type, settings} -> {event_type, Map.merge(%{enabled: true, threshold: nil}, settings)} end)
  end

  def update(event_type, attrs) do
    %__MODULE__{}
    |> cast(attrs, [:event_type, :enabled, :threshold])
    |> validate_required([:event_type])
    |> unique_constraint(:event_type)
    |> Repo.upsert()
  end

  def enabled?(event_type) do
    query =
      from(ns in __MODULE__,
        where: ns.event_type == ^event_type,
        select: ns.enabled
      )

    Repo.one(query, default: true)
  end
end
