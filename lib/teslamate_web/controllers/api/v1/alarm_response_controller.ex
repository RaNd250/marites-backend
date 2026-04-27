defmodule TeslaMateWeb.API.V1.AlarmResponseController do
  use TeslaMateWeb, :controller

  alias TeslaMate.AlarmResponse.Settings

  def show(conn, _params) do
    user_id = conn.assigns.current_user.id
    prefs = Settings.get(user_id)
    json(conn, prefs)
  end

  def update(conn, params) do
    user_id = conn.assigns.current_user.id
    attrs = Map.take(params, ["honk_on_alarm", "flash_on_alarm"])

    case Settings.upsert(user_id, attrs) do
      {:ok, row} ->
        json(conn, %{honk_on_alarm: row.honk_on_alarm, flash_on_alarm: row.flash_on_alarm})

      {:error, changeset} ->
        conn |> put_status(422) |> json(%{error: inspect(changeset.errors)})
    end
  end
end
