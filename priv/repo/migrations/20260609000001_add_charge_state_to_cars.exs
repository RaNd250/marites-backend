defmodule Marites.Repo.Migrations.AddSoftwareVersionToCars do
  use Ecto.Migration
  def change do
    alter table(:cars) do
      add_if_not_exists :software_version, :string, null: true
      add_if_not_exists :charge_state, :string, null: true
    end
  end
end
