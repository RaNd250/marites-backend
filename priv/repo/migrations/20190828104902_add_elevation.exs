defmodule Marites.Repo.Migrations.AddElevation do
  use Ecto.Migration

  def change do
    rename(table(:positions), :altitude, to: :elevation)
  end
end
