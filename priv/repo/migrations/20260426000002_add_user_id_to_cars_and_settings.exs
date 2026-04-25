defmodule TeslaMate.Repo.Migrations.AddUserIdToCarsAndSettings do
  use Ecto.Migration

  def change do
    alter table(:cars) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:cars, [:user_id])

    alter table(:notification_settings) do
      add :user_id,  references(:users, on_delete: :delete_all)
      add :delivery, :string, null: false, default: "push"
    end

    create index(:notification_settings, [:user_id])
    create unique_index(:notification_settings, [:user_id, :event_type])
  end
end
