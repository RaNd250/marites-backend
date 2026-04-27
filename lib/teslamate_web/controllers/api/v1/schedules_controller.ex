defmodule TeslaMateWeb.API.V1.SchedulesController do
  use TeslaMateWeb, :controller

  alias TeslaMate.SentrySchedule
  alias TeslaMate.{Repo, Log.Car}
  import Ecto.Query

  def show(conn, %{"car_id" => car_id_str}) do
    car_id = String.to_integer(car_id_str)
    user_id = conn.assigns.current_user.id

    case verify_car_owner(car_id, user_id) do
      :error ->
        conn |> put_status(404) |> json(%{error: "car not found"})

      :ok ->
        case SentrySchedule.for_car(car_id, user_id) do
          nil      -> conn |> put_status(404) |> json(%{error: "no schedule"})
          schedule -> json(conn, serialize(schedule))
        end
    end
  end

  def update(conn, %{"car_id" => car_id_str} = params) do
    car_id = String.to_integer(car_id_str)
    user_id = conn.assigns.current_user.id

    case verify_car_owner(car_id, user_id) do
      :error ->
        conn |> put_status(404) |> json(%{error: "car not found"})

      :ok ->
        attrs = Map.take(params, ["enabled", "on_hour", "on_minute", "off_hour", "off_minute"])

        case SentrySchedule.upsert(user_id, car_id, attrs) do
          {:ok, schedule} ->
            json(conn, serialize(schedule))

          {:error, changeset} ->
            conn |> put_status(422) |> json(%{error: format_errors(changeset)})
        end
    end
  end

  def delete(conn, %{"car_id" => car_id_str}) do
    car_id = String.to_integer(car_id_str)
    user_id = conn.assigns.current_user.id
    SentrySchedule.delete(car_id, user_id)
    json(conn, %{ok: true})
  end

  defp verify_car_owner(car_id, user_id) do
    case Repo.one(from c in Car, where: c.id == ^car_id and c.user_id == ^user_id, select: c.id) do
      nil -> :error
      _   -> :ok
    end
  end

  defp serialize(s) do
    %{
      id:         s.id,
      car_id:     s.car_id,
      enabled:    s.enabled,
      on_hour:    s.on_hour,
      on_minute:  s.on_minute,
      off_hour:   s.off_hour,
      off_minute: s.off_minute
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
  end
end
