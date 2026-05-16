defmodule MaritesWeb.API.V1.SentryEventsController do
  use MaritesWeb, :controller

  alias Marites.Repo
  alias Marites.SentryEvent
  alias Marites.Log.Car
  import Ecto.Query

  def index(conn, params) do
    user_id = conn.assigns.current_user.id
    car_id = parse_int(params["car_id"])
    limit = params["limit"] |> parse_int() |> limit_clamp(50, 200)

    user_car_ids = Repo.all(from c in Car, where: c.user_id == ^user_id, select: c.id)

    query =
      from e in SentryEvent,
        where: e.car_id in ^user_car_ids,
        order_by: [desc: e.activated_at],
        limit: ^limit

    query = if car_id, do: where(query, [e], e.car_id == ^car_id), else: query

    json(conn, Enum.map(Repo.all(query), &format_event/1))
  end

  defp format_event(e) do
    %{
      id: e.id, car_id: e.car_id, activated_at: e.activated_at,
      deactivated_at: e.deactivated_at, duration_seconds: e.duration_seconds,
      lat: e.start_lat, lng: e.start_lng
    }
  end

  defp parse_int(nil), do: nil
  defp parse_int(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> nil
    end
  end

  defp limit_clamp(nil, default, _max), do: default
  defp limit_clamp(n, _default, max), do: min(n, max)
end
