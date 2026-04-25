defmodule TeslaMateWeb.API.V1.StatsController do
  use TeslaMateWeb, :controller

  alias TeslaMate.Repo
  alias TeslaMate.Log.{Car, Position, Drive}
  import Ecto.Query

  def index(conn, params) do
    user_id = conn.assigns.current_user.id
    car_id = parse_int(params["car_id"])
    user_car_ids = Repo.all(from c in Car, where: c.user_id == ^user_id, select: c.id)

    json(conn, %{
      battery_health: battery_health(user_car_ids, car_id),
      monthly_km: monthly_km(user_car_ids, car_id)
    })
  end

  defp battery_health(user_car_ids, car_id) do
    cutoff = DateTime.add(DateTime.utc_now(), -90, :day)

    query =
      from p in Position,
        where: p.car_id in ^user_car_ids and p.date >= ^cutoff and not is_nil(p.rated_battery_range_km),
        group_by: fragment("TO_CHAR(? AT TIME ZONE 'UTC', 'YYYY-MM-DD')", p.date),
        select: %{
          date: fragment("TO_CHAR(? AT TIME ZONE 'UTC', 'YYYY-MM-DD')", p.date),
          rated_range_km: max(p.rated_battery_range_km)
        },
        order_by: fragment("TO_CHAR(? AT TIME ZONE 'UTC', 'YYYY-MM-DD')", p.date)

    query = if car_id, do: where(query, [p], p.car_id == ^car_id), else: query

    Repo.all(query) |> Enum.map(&%{date: &1.date, rated_range_km: to_float(&1.rated_range_km)})
  end

  defp monthly_km(user_car_ids, car_id) do
    cutoff = DateTime.add(DateTime.utc_now(), -365, :day)

    query =
      from d in Drive,
        where: d.car_id in ^user_car_ids and d.end_date >= ^cutoff and not is_nil(d.distance),
        group_by: fragment("TO_CHAR(DATE_TRUNC('month', ? AT TIME ZONE 'UTC'), 'YYYY-MM')", d.end_date),
        select: %{
          month: fragment("TO_CHAR(DATE_TRUNC('month', ? AT TIME ZONE 'UTC'), 'YYYY-MM')", d.end_date),
          total_km: sum(d.distance)
        },
        order_by: fragment("TO_CHAR(DATE_TRUNC('month', ? AT TIME ZONE 'UTC'), 'YYYY-MM')", d.end_date)

    query = if car_id, do: where(query, [d], d.car_id == ^car_id), else: query

    Repo.all(query) |> Enum.map(&%{month: &1.month, total_km: to_float(&1.total_km)})
  end

  defp to_float(nil), do: nil
  defp to_float(%Decimal{} = d), do: Decimal.to_float(d)
  defp to_float(v), do: v

  defp parse_int(nil), do: nil
  defp parse_int(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> nil
    end
  end
end
