import Config

config :marites, MaritesWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "scripts/build.js",
      cd: Path.expand("../assets", __DIR__),
      env: %{"NODE_ENV" => "development"}
    ]
  ],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/marites_web/(live|views)/.*(ex)$",
      ~r"lib/marites_web/templates/.*(eex)$",
      ~r"grafana/dashboards/.*(json)$"
    ]
  ]

config :logger, :console, format: "$metadata[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :marites, Marites.Repo, show_sensitive_data_on_connection_error: true
config :marites, disable_token_refresh: true
