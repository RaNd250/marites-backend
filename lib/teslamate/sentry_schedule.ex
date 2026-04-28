defmodule TeslaMate.SentrySchedule do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias TeslaMate.Repo

  schema "sentry_schedules" do
    field :user_id,     :integer
    field :car_id,      :integer
    field :day_of_week, :integer
    field :enabled,     :boolean, default: true
    field :on_hour,     :integer
    field :on_minute,   :integer
    field :off_hour,    :integer
    field :off_minute,  :integer
    timestamps()
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:user_id, :car_id, :day_of_week, :enabled, :on_hour, :on_minute, :off_hour, :off_minute])
    |> validate_required([:user_id, :car_id, :day_of_week, :on_hour, :on_minute, :off_hour, :off_minute])
    |> validate_inclusion(:day_of_week, 0..6)
    |> validate_inclusion(:on_hour,     0..23)
    |> validate_inclusion(:off_hour,    0..23)
    |> validate_inclusion(:on_minute,   0..59)
    |> validate_inclusion(:off_minute,  0..59)
  end

  def for_car(car_id, user_id) do
    Repo.all(
      from s in __MODULE__,
        where: s.car_id == ^car_id and s.user_id == ^user_id,
        order_by: s.day_of_week
    )
  end

  defp upsert_day(user_id, car_id, day_of_week, attrs) do
    case Repo.one(
           from s in __MODULE__,
             where: s.car_id == ^car_id and s.user_id == ^user_id and s.day_of_week == ^day_of_week
         ) do
      nil ->
        %__MODULE__{}
        |> changeset(Map.merge(attrs, %{"user_id" => user_id, "car_id" => car_id, "day_of_week" => day_of_week}))
        |> Repo.insert()

      existing ->
        existing
        |> changeset(attrs)
        |> Repo.update()
    end
  end

  def upsert_all(user_id, car_id, days) when is_list(days) do
    Repo.transaction(fn ->
      Enum.map(days, fn day ->
        dow = day["day_of_week"] || day[:day_of_week]

        case upsert_day(user_id, car_id, dow, day) do
          {:ok, row}   -> row
          {:error, cs} -> Repo.rollback(cs)
        end
      end)
    end)
  end

  def delete(car_id, user_id) do
    Repo.delete_all(
      from s in __MODULE__, where: s.car_id == ^car_id and s.user_id == ^user_id
    )
    :ok
  end
end
