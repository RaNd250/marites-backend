defmodule MaritesWeb.VcpKeyController do
  use MaritesWeb, :controller

  # Serves the Tesla VCP (Virtual Command Protocol) public key.
  # Tesla fetches this before allowing users to pair via https://tesla.com/_ak/app.marit.es
  # The key is loaded from the TESLA_VCP_PUBLIC_KEY env var (PEM string).
  def show(conn, _params) do
    case System.get_env("TESLA_VCP_PUBLIC_KEY") do
      nil ->
        conn
        |> put_status(503)
        |> text("VCP public key not configured")

      pem ->
        conn
        |> put_resp_content_type("application/x-pem-file")
        |> put_resp_header("cache-control", "public, max-age=86400")
        |> text(pem)
    end
  end
end
