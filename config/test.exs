import Config

config :logger, level: :warning

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :Marites, MaritesWeb.Endpoint, server: false
config :Marites, Marites.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :phoenix, :plug_init_mode, :runtime
