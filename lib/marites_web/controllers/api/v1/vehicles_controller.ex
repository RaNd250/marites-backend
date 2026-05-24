defmodule MaritesWeb.API.V1.VehiclesController do
  use MaritesWeb, :controller

  alias Marites.{Repo, Accounts}
  alias Marites.Log.{Car, State, Position, ChargingProcess, Charge}
  alias Marites.FCM.TokenStore
  import Ecto.Query

  def status(conn, _params) do
    user = conn.assigns.current_user
    user_id = user.id
    all_cars = Repo.all(from c in Car, where: c.user_id == ^user_id)

    cars =
      if lite_edition?(user_id) do
        selected = Enum.find(all_cars, fn c -> c.id == user.selected_car_id end) || List.first(all_cars)
        if selected, do: [selected], else: []
      else
        all_cars
      end

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

        latest_charge =
          if latest_state && to_string(latest_state.state) == "charging" do
            active_process =
              Repo.one(
                from cp in ChargingProcess,
                  where: cp.car_id == ^car.id and is_nil(cp.end_date),
                  order_by: [desc: cp.start_date],
                  limit: 1
              )

            if active_process do
              Repo.one(
                from c in Charge,
                  where: c.charging_process_id == ^active_process.id,
                  order_by: [desc: c.date],
                  limit: 1
              )
            end
          end

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
          inside_temp: to_float(pos_field(latest_pos, :inside_temp)),
          outside_temp: to_float(pos_field(latest_pos, :outside_temp)),
          updated_at: pos_field(latest_pos, :date),
          charger_power: charge_field(latest_charge, :charger_power),
          charger_voltage: charge_field(latest_charge, :charger_voltage),
          fast_charger_present: charge_field(latest_charge, :fast_charger_present),
          fast_charger_brand: charge_field(latest_charge, :fast_charger_brand),
          charge_energy_added: to_float(charge_field(latest_charge, :charge_energy_added)),
          virtual_key_paired: car.virtual_key_paired
        }
      end)

    json(conn, result)
  end

  def suspend_logging(conn, %{"car_id" => car_id_str}) do
    user_id = conn.assigns.current_user.id
    car_id = String.to_integer(car_id_str)

    case Repo.one(from c in Car, where: c.id == ^car_id and c.user_id == ^user_id) do
      nil -> conn |> put_status(404) |> json(%{error: "car not found"})
      car ->
        case Marites.Vehicles.suspend_logging(car.id) do
          :ok -> json(conn, %{ok: true})
          {:error, _reason} -> conn |> put_status(422) |> json(%{error: "could not suspend logging"})
        end
    end
  end

  def resume_logging(conn, %{"car_id" => car_id_str}) do
    user_id = conn.assigns.current_user.id
    car_id = String.to_integer(car_id_str)

    case Repo.one(from c in Car, where: c.id == ^car_id and c.user_id == ^user_id) do
      nil -> conn |> put_status(404) |> json(%{error: "car not found"})
      car ->
        :ok = Marites.Vehicles.resume_logging(car.id)
        json(conn, %{ok: true})
    end
  end

  def select_vehicle(conn, %{"car_id" => car_id_raw}) do
    user_id = conn.assigns.current_user.id

    with {car_id, _} <- Integer.parse(to_string(car_id_raw)),
         true <- Repo.exists?(from c in Car, where: c.id == ^car_id and c.user_id == ^user_id) do
      Accounts.update_selected_car(user_id, car_id)
      json(conn, %{ok: true})
    else
      _ -> conn |> put_status(400) |> json(%{error: "invalid car_id"})
    end
  end

  defp lite_edition?(user_id) do
    not TokenStore.any_core_token?(user_id) and
      TokenStore.tokens_for_user(user_id, "lite") != []
  end

  defp pos_field(nil, _field), do: nil
  defp pos_field(pos, field), do: Map.get(pos, field)

  defp charge_field(nil, _field), do: nil
  defp charge_field(charge, field), do: Map.get(charge, field)

  defp to_float(nil), do: nil
  defp to_float(%Decimal{} = d), do: Decimal.to_float(d)
  defp to_float(v), do: v
end
