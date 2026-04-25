defmodule TeslaMateWeb.API.V1.AccountController do
  use TeslaMateWeb, :controller

  alias TeslaMate.Accounts

  def me(conn, _params) do
    user = conn.assigns.current_user
    has_tesla = Accounts.get_tesla_token(user.id) != nil

    json(conn, %{
      id: user.id,
      email: user.email,
      admin: user.admin,
      history_enabled: user.history_enabled,
      notification_email: user.notification_email,
      tesla_connected: has_tesla
    })
  end

  def delete_data(conn, _params) do
    user_id = conn.assigns.current_user.id

    case Accounts.delete_user_data(user_id) do
      {:ok, _} -> json(conn, %{ok: true})
      {:error, reason} -> conn |> put_status(500) |> json(%{error: inspect(reason)})
    end
  end

  def delete_account(conn, %{"refresh_token" => raw_token}) do
    user_id = conn.assigns.current_user.id
    Accounts.revoke_refresh_token(raw_token)

    case Accounts.delete_account(user_id) do
      {:ok, _} -> json(conn, %{ok: true})
      {:error, reason} -> conn |> put_status(500) |> json(%{error: inspect(reason)})
    end
  end

  def delete_account(conn, _params) do
    user_id = conn.assigns.current_user.id

    case Accounts.delete_account(user_id) do
      {:ok, _} -> json(conn, %{ok: true})
      {:error, reason} -> conn |> put_status(500) |> json(%{error: inspect(reason)})
    end
  end
end
