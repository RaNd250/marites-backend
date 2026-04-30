defmodule MaritesWeb.API.V1.VehiclesController do
  use MaritesWeb, :controller

  alias Marites.Repo
  alias Marites.Log.{Car, State, Position}
  import Ecto.Query

  def status(conn, _params) do
    user_id = conn.assigns.current_user.id
    cars = Repo.all(from c in Car, where: c.user_id == ^user_id)

    result =
      Enum.map(cars, fn car ->
        latest_state =
          Repo.one(
            from s in State,
              where: s.car_id == ^car.id,
              order_by: [desc: s.start_date],
              limit: 1
          )

        latest_pos =
          Repo.one(
            from p in Position,
              where: p.car_id == ^car.id,
              order_by: [desc: p.date],
              limit: 1
          )

        %{
          id: car.id,
          name: car.name,
          vin: car.vin,
          model: car.model,
          state: if(latest_state, do: to_string(latest_state.state), else: nil),
          battery_level: pos_field(latest_pos, :battery_level),
          rated_battery_range_km: to_float(pos_field(latest_pos, :rated_battery_range_km)),
          latitude: to_float(pos_field(latest_pos, :latitude)),
          longitude: to_float(pos_field(latest_pos, :longitude)),
          odometer: pos_field(latest_pos, :odometer),
          speed: pos_field(latest_pos, :speed),
          updated_at: pos_field(latest_pos, :date)
        }
      end)

    json(conn, result)
  end

  defp pos_field(nil, _field), do: nil
  defp pos_field(pos, field), do: Map.get(pos, field)

  defp to_float(nil), do: nil
  defp to_float(%Decimal{} = d), do: Decimal.to_float(d)
  defp to_float(v), do: v
end
