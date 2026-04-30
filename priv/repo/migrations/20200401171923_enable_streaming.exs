defmodule Marites.Repo.Migrations.EnableStreaming do
  use Ecto.Migration

  alias Marites.Settings.CarSettings
  alias Marites.Repo

  def up, do: Repo.update_all(CarSettings, set: [use_streaming_api: true])
  def down, do: :ok
end
