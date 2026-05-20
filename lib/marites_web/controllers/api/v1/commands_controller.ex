defmodule MaritesWeb.API.V1.CommandsController do
  use MaritesWeb, :controller

  alias Marites.{Api, Repo}
  alias Marites.Log.Car
  import Ecto.Query

  @allowed ~w(sentry_on sentry_off honk_horn flash_lights)

  def run(conn, %{"car_id" => car_id_str, "command" => command})
      when command in @allowed do
    car_id = String.to_integer(car_id_str)
    user_id = conn.assigns.current_user.id

    case Repo.one(
           from c in Car,
             where: c.id == ^car_id and c.user_id == ^user_id,
             select: c.vin
         ) do
      nil ->
        conn |> put_status(404) |> json(%{error: "car not found"})

      vin ->
        {tesla_cmd, body} = map_command(command)

        if not Marites.UserApiSupervisor.running?(user_id) do
          conn
          |> put_status(503)
          |> json(%{error: "not_signed_in"})
        else
          api_name = Marites.ApiRegistry.via(user_id)

          case Api.run_command(api_name, vin, tesla_cmd, body) do
            {:ok, _} ->
              json(conn, %{ok: true})

            {:error, {:command_failed, reason}} ->
              conn |> put_status(422) |> json(%{error: reason})

            {:error, :vehicle_unavailable} ->
              conn
              |> put_status(503)
              |> json(%{error: "vehicle is asleep — wake it from the Tesla app first"})

            {:error, :not_signed_in} ->
              conn
              |> put_status(503)
              |> json(%{error: "not_signed_in"})

            {:error, :unauthorized} ->
              conn
              |> put_status(503)
              |> json(%{error: "Tesla authentication expired — reconnecting, please try again in a moment"})

            {:error, :account_disabled} ->
              conn
              |> put_status(503)
              |> json(%{error: "commands_unavailable", message: "Vehicle commands are not yet enabled for this app. Please check back soon."})

            {:error, :missing_scope} ->
              conn
              |> put_status(403)
              |> json(%{error: "missing_scope"})

            {:error, {:command_unauthorized, _}} ->
              pairing_url = "https://tesla.com/_ak/app.marit.es"

              conn
              |> put_status(403)
              |> json(%{error: "command_unauthorized", pairing_url: pairing_url})

            {:error, reason} ->
              conn |> put_status(500) |> json(%{error: inspect(reason)})
          end
        end
    end
  end

  def run(conn, _),
    do: conn |> put_status(400) |> json(%{error: "unknown command"})

  defp map_command("sentry_on"),    do: {"set_sentry_mode", %{"on" => true}}
  defp map_command("sentry_off"),   do: {"set_sentry_mode", %{"on" => false}}
  defp map_command("honk_horn"),    do: {"honk_horn", %{}}
  defp map_command("flash_lights"), do: {"flash_lights", %{}}
end
