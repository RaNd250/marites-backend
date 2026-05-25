defmodule MaritesWeb.API.V1.AdminController do
  use MaritesWeb, :controller

  alias Marites.Accounts
  alias Marites.FleetTelemetry.Registrar
  alias Marites.AuditLogger

  def create_invite(conn, _params) do
    admin_id = conn.assigns.current_user.id

    case Accounts.create_invite_code(admin_id) do
      {:ok, invite} -> json(conn, %{code: invite.code})
      {:error, _cs} -> conn |> put_status(422) |> json(%{error: "could not create invite"})
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
    target_id = String.to_integer(id)

    case Accounts.revoke_user(target_id) do
      {:ok, _} ->
        AuditLogger.log(conn, "admin.revoke_user", metadata: %{target_user_id: target_id})
        json(conn, %{ok: true})

      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: "not found"})

      {:error, _cs} ->
        conn |> put_status(422) |> json(%{error: "could not revoke user"})
    end
  end

  def list_audit_logs(conn, params) do
    import Ecto.Query
    alias Marites.{AuditLog, Repo}

    limit  = min(String.to_integer(params["limit"]  || "100"), 500)
    offset = String.to_integer(params["offset"] || "0")

    query =
      from l in AuditLog,
        order_by: [desc: l.inserted_at],
        limit: ^limit,
        offset: ^offset

    query =
      case params["action"] do
        nil -> query
        a   -> where(query, [l], l.action == ^a)
      end

    query =
      case params["user_id"] do
        nil -> query
        uid -> where(query, [l], l.user_id == ^String.to_integer(uid))
      end

    logs = Repo.all(query)

    json(conn, Enum.map(logs, fn l ->
      %{
        id:          l.id,
        user_id:     l.user_id,
        action:      l.action,
        ip:          l.ip,
        vin:         l.vin,
        result:      l.result,
        metadata:    l.metadata,
        inserted_at: l.inserted_at
      }
    end))
  end

  def register_fleet_telemetry(conn, _params) do
    results =
      Registrar.register_all()
      |> Enum.map(fn {vin, result} ->
        case result do
          {:ok, resp}      -> %{vin: vin, ok: true,  response: resp}
          {:error, reason} -> %{vin: vin, ok: false, error: inspect(reason)}
        end
      end)

    json(conn, %{results: results})
  end
end
