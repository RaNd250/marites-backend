import Config

config :marites,
  ecto_repos: [Marites.Repo]

config :marites, :session_signing_salt, "wK7rPmX4nQs2vBtJ"

config :marites, MaritesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Kz7vmP1gPYv/sogke6P3RP9uipMjOLhneQdbokZVx5gpLsNaN44TD20vtOWkMFIT",
  render_errors: [view: MaritesWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Marites.PubSub,
  live_view: [signing_salt: "6nSVV0NtBtBfA9Mjh+7XaZANjp9T73XH"]

config :marites,
  cloak_repo: Marites.Repo,
  cloak_schemas: [
    Marites.Auth.Tokens
  ]

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
