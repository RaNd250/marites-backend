defmodule Marites.Notifications.Settings do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Marites.Repo

  @valid_delivery ~w(push email none)

  schema "notification_settings" do
    field :user_id,    :integer
    field :event_type, :string
    field :enabled,    :boolean, default: true
    field :threshold,  :integer
    field :delivery,   :string,  default: "push"
    timestamps()
  end

  @event_types ~w(sentry_activated sentry_deactivated sentry_alarm drive_started charge_complete charge_started)

  def get_all(user_id) do
    rows =
      Repo.all(from ns in __MODULE__, where: ns.user_id == ^user_id)
      |> Enum.into(%{}, &{&1.event_type, %{enabled: &1.enabled, threshold: &1.threshold, delivery: &1.delivery}})

    Enum.into(@event_types, %{}, fn et ->
      {et, Map.get(rows, et, %{enabled: true, threshold: nil, delivery: "push"})}
    end)
  end

  def update(user_id, event_type, attrs) do
    %__MODULE__{user_id: user_id, event_type: event_type}
    |> cast(attrs, [:enabled, :threshold, :delivery])
    |> put_change(:user_id, user_id)
    |> put_change(:event_type, event_type)
    |> validate_required([:event_type, :user_id])
    |> validate_inclusion(:delivery, @valid_delivery)
    |> validate_number(:threshold, greater_than: 0, less_than_or_equal_to: 3600)
    |> Repo.insert(
      on_conflict: {:replace, [:enabled, :threshold, :delivery, :updated_at]},
      conflict_target: [:user_id, :event_type]
    )
  end

  def get_delivery(user_id, event_type) do
    from(ns in __MODULE__,
      where: ns.user_id == ^user_id and ns.event_type == ^event_type,
      select: {ns.enabled, ns.delivery}
    )
    |> Repo.one()
    |> case do
      nil -> {true, "push"}
      {enabled, delivery} -> {enabled, delivery}
    end
  end

  def get_delivery_with_threshold(user_id, event_type) do
    from(ns in __MODULE__,
      where: ns.user_id == ^user_id and ns.event_type == ^event_type,
      select: {ns.enabled, ns.delivery, ns.threshold}
    )
    |> Repo.one()
    |> case do
      nil -> {true, "push", nil}
      {enabled, delivery, threshold} -> {enabled, delivery, threshold}
    end
  end
end
