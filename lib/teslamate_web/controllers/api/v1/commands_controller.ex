defmodule TeslaMateWeb.API.V1.CommandsController do
  use TeslaMateWeb, :controller

  alias TeslaMate.{Api, Repo}
  alias TeslaMate.Log.Car
  import Ecto.Query

  @allowed ~w(sentry_on sentry_off honk_horn flash_lights)

  def run(conn, %{"car_id" => car_id_str, "command" => command})
      when command in @allowed do
    car_id = String.to_integer(car_id_str)
    user_id = conn.assigns.current_user.id

    case Repo.one(
           from c in Car,
             where: c.id == ^car_id and c.user_id == ^user_id,
             select: c.eid
         ) do
      nil ->
        conn |> put_status(404) |> json(%{error: "car not found"})

      eid ->
        {tesla_cmd, body} = map_command(command)

        case Api.run_command(eid, tesla_cmd, body) do
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
            |> json(%{error: "TeslaMi is not authenticated with Tesla — please sign in at the web interface"})

          {:error, :unauthorized} ->
            conn
            |> put_status(503)
            |> json(%{error: "Tesla authentication expired — reconnecting, please try again in a moment"})

          {:error, reason} ->
            conn |> put_status(500) |> json(%{error: inspect(reason)})
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
