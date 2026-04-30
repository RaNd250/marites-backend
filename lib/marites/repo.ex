defmodule Marites.Repo do
  use Ecto.Repo,
    otp_app: :marites,
    adapter: Ecto.Adapters.Postgres
end
