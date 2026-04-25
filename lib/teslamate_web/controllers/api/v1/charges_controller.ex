defmodule TeslaMateWeb.API.V1.ChargesController do
  use TeslaMateWeb, :controller

  alias TeslaMate.Repo
  alias TeslaMate.Log.ChargingProcess
  import Ecto.Query

  def index(conn, params) do
    car_id = parse_int(params["car_id"])
    limit = params["limit"] |> parse_int() |> limit_clamp(50, 200)

    query =
      from c in ChargingProcess,
        where: not is_nil(c.end_date),
        order_by: [desc: c.start_date],
        limit: ^limit,
        preload: [:address, :geofence]

    query = if car_id, do: where(query, [c], c.car_id == ^car_id), else: query

    json(conn, Enum.map(Repo.all(query), &format_charge/1))
  end

  defp format_charge(c) do
    %{
      id: c.id,
      car_id: c.car_id,
      start_date: c.start_date,
      end_date: c.end_date,
      duration_min: c.duration_min,
      energy_added_kwh: to_float(c.charge_energy_added),
      start_battery_level: c.start_battery_level,
      end_battery_level: c.end_battery_level,
      location: address_label(c.geofence, c.address)
    }
  end

  defp address_label(geofence, address) do
    cond do
      geofence -> geofence.name
      address -> address.display_name
      true -> nil
    end
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
