import Config

config :marites,
  ecto_repos: [Marites.Repo]

config :marites, :session_signing_salt, System.get_env("SESSION_SIGNING_SALT", "dev-signing-salt-change-in-prod")

config :marites, MaritesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE", String.duplicate("dev-secret-key-base-do-not-use-in-production", 2)),
  render_errors: [view: MaritesWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Marites.PubSub,
  live_view: [signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT", "dev-lv-salt-change-in-prod")]


config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:car_id]

config :phoenix,
  json_library: Jason,
  static_compressors: [
    PhoenixBakery.Gzip,
    PhoenixBakery.Brotli,
    PhoenixBakery.Zstd
  ]

config :gettext, :default_locale, "en"

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

import_config "#{config_env()}.exs"
