defmodule MaritesWeb.API.V1.DrivesController do
  use MaritesWeb, :controller

  alias Marites.Repo
  alias Marites.Log.{Car, Drive}
  import Ecto.Query

  def index(conn, params) do
    user_id = conn.assigns.current_user.id
    car_id = parse_int(params["car_id"])
    limit = params["limit"] |> parse_int() |> limit_clamp(50, 200)

    user_car_ids = Repo.all(from c in Car, where: c.user_id == ^user_id, select: c.id)

    query =
      from d in Drive,
        where: d.car_id in ^user_car_ids and not is_nil(d.end_date),
        order_by: [desc: d.start_date],
        limit: ^limit,
        preload: [:start_address, :end_address, :start_geofence, :end_geofence]

    query = if car_id, do: where(query, [d], d.car_id == ^car_id), else: query

    json(conn, Enum.map(Repo.all(query), &format_drive/1))
  end

  def show(conn, %{"id" => id}) do
    user_id = conn.assigns.current_user.id
    user_car_ids = Repo.all(from c in Car, where: c.user_id == ^user_id, select: c.id)

    drive =
      from(d in Drive, where: d.id == ^id and d.car_id in ^user_car_ids)
      |> Repo.one()
      |> case do
        nil -> nil
        d -> Repo.preload(d, [:start_address, :end_address, :start_geofence, :end_geofence, :positions])
      end

    if drive do
      json(conn, Map.put(format_drive(drive), :positions, Enum.map(drive.positions, &format_position/1)))
    else
      conn |> put_status(404) |> json(%{error: "not found"})
    end
  end

  defp format_drive(d) do
    %{
      id: d.id, car_id: d.car_id, start_date: d.start_date, end_date: d.end_date,
      distance_km: d.distance, duration_min: d.duration_min, speed_max: d.speed_max,
      outside_temp_avg: to_float(d.outside_temp_avg),
      start_address: address_label(d.start_geofence, d.start_address),
      end_address: address_label(d.end_geofence, d.end_address),
      start_lat: address_coord(d.start_address, :latitude),
      start_lng: address_coord(d.start_address, :longitude),
      end_lat: address_coord(d.end_address, :latitude),
      end_lng: address_coord(d.end_address, :longitude)
    }
  end

  defp address_coord(nil, _), do: nil
  defp address_coord(addr, field), do: to_float(Map.get(addr, field))

  defp address_label(geofence, address) do
    cond do
      geofence -> geofence.name
      address -> address.display_name
      true -> nil
    end
  end

  defp format_position(p) do
    %{date: p.date, lat: to_float(p.latitude), lng: to_float(p.longitude),
      speed: p.speed, battery_level: p.battery_level}
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

  defp limit_clamp(nil, default, _max), do: default
  defp limit_clamp(n, _default, max), do: min(n, max)
end
