defmodule Marites.Repo.Migrations.AddVirtualKeyPairedToCars do
  use Ecto.Migration

  def change do
    alter table(:cars) do
      add :virtual_key_paired, :boolean, default: false, null: false
    end
  end
end
