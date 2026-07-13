defmodule Marites.Repo.Migrations.AddPlanToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :plan, :string, null: false, default: "free"
    end

    # Seed existing Core users (user_id=1 is the owner account)
    execute "UPDATE users SET plan = 'core' WHERE id = 1", ""
  end
end
