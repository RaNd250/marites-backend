defmodule Marites.AuditLogger do
  @moduledoc """
  Inserts audit log entries asynchronously so logging never blocks a response.

  Usage:
    AuditLogger.log(conn, "auth.login", result: "ok")
    AuditLogger.log(conn, "command.sentry_on", result: "ok", vin: vin)
    AuditLogger.log(conn, "auth.login", result: "fail", metadata: %{reason: "bad_credentials"})
  """

  alias Marites.{AuditLog, Repo}

  @spec log(Plug.Conn.t(), String.t(), keyword()) :: :ok
  def log(conn, action, opts \\ []) do
    user = conn.assigns[:current_user]
    ip = client_ip(conn)

    entry = %{
      user_id:  if(user, do: user.id),
      action:   action,
      ip:       ip,
      vin:      opts[:vin],
      result:   to_string(opts[:result] || "ok"),
      metadata: opts[:metadata],
      inserted_at: DateTime.utc_now(:second)
    }

    Task.start(fn -> Repo.insert_all(AuditLog, [entry]) end)
    :ok
  end

  # CF-Connecting-IP is set by nginx (from Cloudflare). Fall back to X-Forwarded-For,
  # then the remote IP directly.
  defp client_ip(conn) do
    case get_header(conn, "x-real-ip") do
      nil ->
        case get_header(conn, "x-forwarded-for") do
          nil -> conn.remote_ip |> :inet.ntoa() |> to_string()
          forwarded -> forwarded |> String.split(",") |> List.first() |> String.trim()
        end

      ip ->
        ip
    end
  end

  defp get_header(conn, name) do
    case Plug.Conn.get_req_header(conn, name) do
      [val | _] -> val
      [] -> nil
    end
  end
end
