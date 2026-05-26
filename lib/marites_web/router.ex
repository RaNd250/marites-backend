defmodule MaritesWeb.Router do
  use MaritesWeb, :router

  alias Marites.Settings

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash

    plug Cldr.Plug.AcceptLanguage,
      cldr_backend: MaritesWeb.Cldr,
      no_match_log_level: :debug

    plug Cldr.Plug.PutLocale,
      apps: [:cldr, :gettext],
      from: [:query, :session, :accept_language],
      gettext: MaritesWeb.Gettext,
      cldr: MaritesWeb.Cldr

    plug MaritesWeb.Plugs.PutSession
    plug :put_root_layout, {MaritesWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_settings
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # ---- Tesla OAuth PKCE flow ----
  scope "/auth/tesla", MaritesWeb do
    pipe_through :browser

    get "/", TeslaOAuthController, :authorize
    get "/callback", TeslaOAuthController, :callback
  end

  # ---- Tesla VCP public key (required for vehicle commands) ----
  scope "/.well-known/appspecific", MaritesWeb do
    pipe_through :api
    get "/com.tesla.3p.public-key.pem", VcpKeyController, :show
  end

  # ---- Browser routes (Marites internal UI) ----
  scope "/", MaritesWeb do
    pipe_through :browser

    get "/", CarController, :index
    get "/drive/:id/gpx", DriveController, :gpx

    live_session :default do
      live "/sign_in", SignInLive.Index
      live "/settings", SettingsLive.Index
      live "/geo-fences", GeoFenceLive.Index
      live "/geo-fences/new", GeoFenceLive.Form
      live "/geo-fences/:id/edit", GeoFenceLive.Form
      live "/charge-cost/:id", ChargeLive.Cost
      live "/import", ImportLive.Index
    end
  end

  def fetch_settings(conn, _opts) do
    settings = Settings.get_global_settings!()

    conn
    |> assign(:settings, settings)
    |> put_session(:settings, settings)
  end
end
