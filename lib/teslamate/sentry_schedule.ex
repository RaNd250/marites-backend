defmodule TeslaMate.SentrySchedule do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TeslaMate.Repo

  schema "sentry_schedules" do
    field :user_id,    :integer
    field :car_id,     :integer
    field :enabled,    :boolean, default: true
    field :on_hour,    :integer
    field :on_minute,  :integer
    field :off_hour,   :integer
    field :off_minute, :integer
    timestamps()
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:user_id, :car_id, :enabled, :on_hour, :on_minute, :off_hour, :off_minute])
    |> validate_required([:user_id, :car_id, :on_hour, :on_minute, :off_hour, :off_minute])
    |> validate_inclusion(:on_hour,    0..23)
    |> validate_inclusion(:off_hour,   0..23)
    |> validate_inclusion(:on_minute,  0..59)
    |> validate_inclusion(:off_minute, 0..59)
  end

  def for_car(car_id, user_id) do
    Repo.one(from s in __MODULE__, where: s.car_id == ^car_id and s.user_id == ^user_id)
  end

  def upsert(user_id, car_id, attrs) do
    case for_car(car_id, user_id) do
      nil ->
        %__MODULE__{}
        |> changeset(Map.merge(attrs, %{"user_id" => user_id, "car_id" => car_id}))
        |> Repo.insert()

      existing ->
        existing
        |> changeset(attrs)
        |> Repo.update()
    end
  end

  def delete(car_id, user_id) do
    Repo.delete_all(
      from s in __MODULE__, where: s.car_id == ^car_id and s.user_id == ^user_id
    )
    :ok
  end

  def all_enabled do
    Repo.all(from s in __MODULE__, where: s.enabled == true)
  end
end
