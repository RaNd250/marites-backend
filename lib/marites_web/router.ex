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

  pipeline :authenticated do
    plug MaritesWeb.Plugs.RequireAuth
  end

  pipeline :admin_only do
    plug MaritesWeb.Plugs.RequireAuth
    plug :require_admin
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

  scope "/api", MaritesWeb do
    pipe_through :api
    put "/car/:id/logging/resume", CarController, :resume_logging
    put "/car/:id/logging/suspend", CarController, :suspend_logging
  end

  # ---- Public auth endpoints (no JWT required) ----
  scope "/api/v1/auth", MaritesWeb.API.V1 do
    pipe_through :api

    post   "/register", AuthController, :register
    post   "/login",    AuthController, :login
    post   "/refresh",  AuthController, :refresh
    delete "/logout",   AuthController, :logout
  end

  # ---- Protected API endpoints (JWT required) ----
  scope "/api/v1", MaritesWeb.API.V1 do
    pipe_through [:api, :authenticated]

    get    "/account/me",             AccountController,       :me
    delete "/account/data",           AccountController,       :delete_data
    delete "/account",                AccountController,       :delete_account

    get    "/vehicles/status",        VehiclesController,      :status
    get    "/drives",                 DrivesController,        :index
    get    "/drives/:id",             DrivesController,        :show
    get    "/charges",                ChargesController,       :index
    get    "/sentry_events",          SentryEventsController,  :index
    get    "/stats",                  StatsController,         :index
    get    "/notifications/settings", NotificationsController, :index
    put    "/notifications/settings", NotificationsController, :update
    post   "/fcm/register",           FcmController,           :register
    delete "/fcm/register",           FcmController,           :unregister

    post   "/vehicles/:car_id/commands/:command", CommandsController,  :run
    get    "/vehicles/:car_id/schedule",          SchedulesController, :show
    put    "/vehicles/:car_id/schedule",          SchedulesController, :update
    delete "/vehicles/:car_id/schedule",          SchedulesController, :delete

    get "/alarm-response", AlarmResponseController, :show
    put "/alarm-response", AlarmResponseController, :update
  end

  # ---- Admin-only endpoints ----
  scope "/api/v1/admin", MaritesWeb.API.V1 do
    pipe_through [:api, :admin_only]

    post "/invites",                    AdminController, :create_invite
    get  "/invites",                    AdminController, :list_invites
    get  "/users",                      AdminController, :list_users
    put  "/users/:id/revoke",           AdminController, :revoke_user
    post "/fleet_telemetry/register",   AdminController, :register_fleet_telemetry
  end

  scope "/api/v1/vehicles" do
    pipe_through [:api, :authenticated]

    get "/", MaritesWeb.API.V1.VehiclesController, :index
    get "/:id", MaritesWeb.API.V1.VehiclesController, :show
  end

  def fetch_settings(conn, _opts) do
    settings = Settings.get_global_settings!()

    conn
    |> assign(:settings, settings)
    |> put_session(:settings, settings)
  end

  defp require_admin(conn, _opts) do
    if conn.assigns.current_user.admin do
      conn
    else
      conn
      |> put_status(403)
      |> Phoenix.Controller.json(%{error: "forbidden"})
      |> halt()
    end
  end
end
