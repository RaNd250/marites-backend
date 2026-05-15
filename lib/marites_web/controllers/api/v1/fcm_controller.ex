defmodule MaritesWeb.API.V1.FcmController do
  use MaritesWeb, :controller

  alias Marites.FCM.TokenStore

  def register(conn, %{"device_id" => device_id, "token" => token} = params) do
    user_id = conn.assigns.current_user.id
    edition = Map.get(params, "edition", "core")
    case TokenStore.register(device_id, token, user_id, edition) do
      {:ok, _} ->
        json(conn, %{ok: true})

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{error: format_errors(changeset)})
    end
  end

  def register(conn, _) do
    conn |> put_status(400) |> json(%{error: "device_id and token required"})
  end

  def unregister(conn, %{"device_id" => device_id}) do
    TokenStore.unregister(device_id)
    json(conn, %{ok: true})
  end

  def unregister(conn, _) do
    conn |> put_status(400) |> json(%{error: "device_id required"})
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
  end
end
