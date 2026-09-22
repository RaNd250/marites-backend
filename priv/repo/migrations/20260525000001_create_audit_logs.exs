defmodule Marites.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs) do
      add :user_id,  :integer
      add :action,   :string,  null: false
      add :ip,       :string
      add :vin,      :string
      add :result,   :string,  null: false, default: "ok"
      add :metadata, :map

      timestamps(updated_at: false)
    end

    create index(:audit_logs, [:user_id])
    create index(:audit_logs, [:action])
    create index(:audit_logs, [:inserted_at])
  end
end
