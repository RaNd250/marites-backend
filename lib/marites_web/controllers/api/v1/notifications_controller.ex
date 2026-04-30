defmodule MaritesWeb.API.V1.NotificationsController do
  use MaritesWeb, :controller

  alias Marites.Notifications.Settings

  def index(conn, _params) do
    user_id = conn.assigns.current_user.id
    json(conn, Settings.get_all(user_id))
  end

  def update(conn, %{"event_type" => event_type} = params) do
    user_id = conn.assigns.current_user.id
    attrs = Map.take(params, ["enabled", "threshold", "delivery"])

    case Settings.update(user_id, event_type, attrs) do
      {:ok, _} ->
        json(conn, %{ok: true})

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{error: format_errors(changeset)})
    end
  end

  def update(conn, _), do: conn |> put_status(400) |> json(%{error: "event_type required"})

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
  end
end
