defmodule TeslaMateWeb.API.V1.StatsController do
  use TeslaMateWeb, :controller

  alias TeslaMate.Repo
  alias TeslaMate.Log.{Position, Drive}
  import Ecto.Query

  def index(conn, params) do
    car_id = parse_int(params["car_id"])

    json(conn, %{
      battery_health: battery_health(car_id),
      monthly_km: monthly_km(car_id)
    })
  end

  defp battery_health(car_id) do
    cutoff = DateTime.add(DateTime.utc_now(), -90, :day)

    query =
      from p in Position,
        where: p.date >= ^cutoff and not is_nil(p.rated_battery_range_km),
        group_by: fragment("TO_CHAR(? AT TIME ZONE 'UTC', 'YYYY-MM-DD')", p.date),
        select: %{
          date: fragment("TO_CHAR(? AT TIME ZONE 'UTC', 'YYYY-MM-DD')", p.date),
          rated_range_km: max(p.rated_battery_range_km)
        },
        order_by: fragment("TO_CHAR(? AT TIME ZONE 'UTC', 'YYYY-MM-DD')", p.date)

    query = if car_id, do: where(query, [p], p.car_id == ^car_id), else: query

    Repo.all(query)
    |> Enum.map(fn row ->
      %{date: row.date, rated_range_km: to_float(row.rated_range_km)}
    end)
  end

  defp monthly_km(car_id) do
    cutoff = DateTime.add(DateTime.utc_now(), -365, :day)

    query =
      from d in Drive,
        where: d.end_date >= ^cutoff and not is_nil(d.distance),
        group_by: fragment("TO_CHAR(DATE_TRUNC('month', ? AT TIME ZONE 'UTC'), 'YYYY-MM')", d.end_date),
        select: %{
          month: fragment("TO_CHAR(DATE_TRUNC('month', ? AT TIME ZONE 'UTC'), 'YYYY-MM')", d.end_date),
          total_km: sum(d.distance)
        },
        order_by: fragment("TO_CHAR(DATE_TRUNC('month', ? AT TIME ZONE 'UTC'), 'YYYY-MM')", d.end_date)

    query = if car_id, do: where(query, [d], d.car_id == ^car_id), else: query

    Repo.all(query)
    |> Enum.map(fn row ->
      %{month: row.month, total_km: to_float(row.total_km)}
    end)
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
