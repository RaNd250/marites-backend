defmodule Marites.SentryEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sentry_events" do
    field :car_id,           :integer
    field :activated_at,     :utc_datetime
    field :deactivated_at,   :utc_datetime
    field :duration_seconds, :integer
    field :start_lat,        :float
    field :start_lng,        :float
    timestamps()
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:car_id, :activated_at, :deactivated_at, :duration_seconds,
                    :start_lat, :start_lng])
    |> validate_required([:car_id, :activated_at])
  end
end
