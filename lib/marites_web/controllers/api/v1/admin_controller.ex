defmodule MaritesWeb.API.V1.AdminController do
  use MaritesWeb, :controller

  alias Marites.Accounts

  def create_invite(conn, _params) do
    admin_id = conn.assigns.current_user.id

    case Accounts.create_invite_code(admin_id) do
      {:ok, invite} -> json(conn, %{code: invite.code})
      {:error, cs} -> conn |> put_status(422) |> json(%{error: inspect(cs.errors)})
    end
  end

  def list_invites(conn, _params) do
    admin_id = conn.assigns.current_user.id
    invites = Accounts.list_invite_codes(admin_id)

    json(conn, Enum.map(invites, fn i ->
      %{
        code: i.code,
        used: i.used_by != nil,
        used_at: i.used_at,
        inserted_at: i.inserted_at
      }
    end))
  end

  def list_users(conn, _params) do
    users = Accounts.list_users()

    json(conn, Enum.map(users, fn u ->
      has_tesla = Accounts.get_tesla_token(u.id) != nil
      %{
        id: u.id,
        email: u.email,
        admin: u.admin,
        active: u.active,
        tesla_connected: has_tesla,
        inserted_at: u.inserted_at
      }
    end))
  end

  def revoke_user(conn, %{"id" => id}) do
    case Accounts.revoke_user(String.to_integer(id)) do
      {:ok, _} -> json(conn, %{ok: true})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not found"})
      {:error, cs} -> conn |> put_status(422) |> json(%{error: inspect(cs.errors)})
    end
  end
end
