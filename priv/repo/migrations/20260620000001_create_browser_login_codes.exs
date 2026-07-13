defmodule Marites.Repo.Migrations.CreateBrowserLoginCodes do
  use Ecto.Migration

  def change do
    create table(:browser_login_codes) do
      add :code_hash, :string, null: false
      # null until the app approves the code (then it carries the approving user)
      add :user_id, :integer
      add :approved_at, :utc_datetime
      add :consumed_at, :utc_datetime
      add :expires_at, :utc_datetime, null: false
      add :inserted_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create unique_index(:browser_login_codes, [:code_hash])
    create index(:browser_login_codes, [:expires_at])
  end
end
