defmodule Marites.Repo.Migrations.AddSelectedCarIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :selected_car_id, :integer, null: true
    end
  end
end
