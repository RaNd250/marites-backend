defmodule TeslaMateWeb.API.V1.NotificationsController do
  use TeslaMateWeb, :controller

  alias TeslaMate.Notifications.Settings

  def index(conn, _params) do
    json(conn, Settings.get_all())
  end

  def update(conn, %{"event_type" => event_type} = params) do
    attrs = Map.take(params, ["enabled", "threshold"])

    case Settings.update(event_type, attrs) do
      {:ok, _} ->
        json(conn, %{ok: true})

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{error: format_errors(changeset)})
    end
  end

  def update(conn, _) do
    conn |> put_status(400) |> json(%{error: "event_type required"})
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
  end
end
