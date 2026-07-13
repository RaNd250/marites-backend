defmodule Marites.Repo.Migrations.AddPlanSourceAndStripe do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :plan_source, :string
      add :stripe_customer_id, :string
      add :stripe_subscription_id, :string
    end

    # Backfill ownership for existing entitlements. `play_purchase_token` is added
    # at runtime by marites-api (Application boot), NOT by an engine migration, so
    # it is absent from the engine's migration-test schema and fresh bootstraps.
    # Guard on its existence so this migration is safe in every context.
    execute(
      """
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_name = 'users' AND column_name = 'play_purchase_token'
        ) THEN
          UPDATE users SET plan_source = 'play'
            WHERE play_purchase_token IS NOT NULL AND plan_source IS NULL;
          UPDATE users SET plan_source = 'promo'
            WHERE plan = 'core' AND play_purchase_token IS NULL AND plan_source IS NULL;
        ELSE
          UPDATE users SET plan_source = 'promo'
            WHERE plan = 'core' AND plan_source IS NULL;
        END IF;
      END $$;
      """,
      "SELECT 1"
    )
  end
end
