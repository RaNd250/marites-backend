defmodule TeslaMateWeb.API.V1.SchedulesController do
  use TeslaMateWeb, :controller

  alias TeslaMate.SentrySchedule
  alias TeslaMate.{Repo, Log.Car}
  import Ecto.Query

  def show(conn, %{"car_id" => car_id_str}) do
    car_id = String.to_integer(car_id_str)
    user_id = conn.assigns.current_user.id

    case verify_car_owner(car_id, user_id) do
      :error -> conn |> put_status(404) |> json(%{error: "car not found"})
      :ok ->
        schedules = SentrySchedule.for_car(car_id, user_id)
        json(conn, Enum.map(schedules, &serialize/1))
    end
  end

  def update(conn, %{"car_id" => car_id_str, "days" => days}) do
    car_id = String.to_integer(car_id_str)
    user_id = conn.assigns.current_user.id

    case verify_car_owner(car_id, user_id) do
      :error -> conn |> put_status(404) |> json(%{error: "car not found"})
      :ok ->
        case SentrySchedule.upsert_all(user_id, car_id, days) do
          {:ok, rows}        -> json(conn, Enum.map(rows, &serialize/1))
          {:error, changeset} -> conn |> put_status(422) |> json(%{error: format_errors(changeset)})
        end
    end
  end

  def delete(conn, %{"car_id" => car_id_str}) do
    car_id = String.to_integer(car_id_str)
    user_id = conn.assigns.current_user.id

    case verify_car_owner(car_id, user_id) do
      :error -> conn |> put_status(404) |> json(%{error: "car not found"})
      :ok ->
        SentrySchedule.delete(car_id, user_id)
        json(conn, %{ok: true})
    end
  end

  defp verify_car_owner(car_id, user_id) do
    case Repo.one(from c in Car, where: c.id == ^car_id and c.user_id == ^user_id, select: c.id) do
      nil -> :error
      _   -> :ok
    end
  end

  defp serialize(s) do
    %{
      id:          s.id,
      car_id:      s.car_id,
      day_of_week: s.day_of_week,
      enabled:     s.enabled,
      on_hour:     s.on_hour,
      on_minute:   s.on_minute,
      off_hour:    s.off_hour,
      off_minute:  s.off_minute
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
  end
end
