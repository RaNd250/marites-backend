defmodule MaritesWeb.Plugs.RateLimit do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts), do: opts

  def call(conn, opts) do
    limit = Keyword.get(opts, :limit, 5)
    window_ms = Keyword.get(opts, :window_ms, 60_000)
    key_prefix = Keyword.get(opts, :key, "default")

    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    key = "#{key_prefix}:#{ip}"

    case Hammer.check_rate(key, window_ms, limit) do
      {:allow, _} ->
        conn

      {:deny, _} ->
        conn
        |> put_resp_header("retry-after", to_string(div(window_ms, 1000)))
        |> put_status(:too_many_requests)
        |> json(%{error: "too many requests, please slow down"})
        |> halt()
    end
  end
end
