defmodule MaritesWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :marites

  @session_options [
    store: :cookie,
    key: "_Marites_key",
    signing_salt: "yt5O3CAQ",
    same_site: "Strict"
  ]

  plug MaritesWeb.HealthCheck

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options], transport_log: :debug]

  plug Plug.Static,
    at: "/",
    from: :marites,
    encodings: [{"zstd", ".zst"}, {"br", ".br"}, {"gzip", ".gz"}],
    only: MaritesWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :marites
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug MaritesWeb.Router
end
