defmodule TeslaMateWeb.Router do
  use TeslaMateWeb, :router

  alias TeslaMate.Settings
  alias TeslamateWeb.API.V1

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash

    plug Cldr.Plug.AcceptLanguage,
      cldr_backend: TeslaMateWeb.Cldr,
      no_match_log_level: :debug

    plug Cldr.Plug.PutLocale,
      apps: [:cldr, :gettext],
      from: [:query, :session, :accept_language],
      gettext: TeslaMateWeb.Gettext,
      cldr: TeslaMateWeb.Cldr

    plug TeslaMateWeb.Plugs.PutSession

    plug :put_root_layout, {TeslaMateWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_settings
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TeslaMateWeb do
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

  scope "/api", TeslaMateWeb do
    pipe_through :api

    put "/car/:id/logging/resume", CarController, :resume_logging
    put "/car/:id/logging/suspend", CarController, :suspend_logging
  end

  def fetch_settings(conn, _opts) do
    settings = Settings.get_global_settings!()

    conn
    |> assign(:settings, settings)
    |> put_session(:settings, settings)
  end

  scope "/api/v1", TeslaMateWeb.API.V1 do
    pipe_through :api

    get  "/vehicles/status",          VehiclesController, :status
    get  "/drives",                   DrivesController,   :index
    get  "/drives/:id",               DrivesController,   :show
    get  "/charges",                  ChargesController,  :index
    get  "/sentry_events",            SentryEventsController, :index
    get  "/stats",                    StatsController,    :index
    get  "/notifications/settings",   NotificationsController, :index
    put  "/notifications/settings",   NotificationsController, :update
    post "/fcm/register",             FcmController,      :register
    delete "/fcm/register",           FcmController,      :unregister
  end

  scope "/api/v1/vehicles" do
    pipe_through :api

    get "/", VehiclesController, :index
    get "/:id", VehiclesController, :show
  end
end
