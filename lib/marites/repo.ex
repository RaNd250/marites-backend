defmodule Marites.Repo do
  use Ecto.Repo,
    otp_app: :Marites,
    adapter: Ecto.Adapters.Postgres
end
