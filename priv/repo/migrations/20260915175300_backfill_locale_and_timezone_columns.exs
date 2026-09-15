defmodule Marites.Repo.Migrations.BackfillLocaleAndTimezoneColumns do
  @moduledoc """
  These four columns are already live on PRIMARY (and preprod) -- they were
  added by raw SQL at some point (unclear when, no audit trail), never
  through an Ecto migration, so `schema_migrations` never recorded them.
  Confirmed by migrating a throwaway database from *only* the committed
  migration files (elixir:1.19.5, fresh Postgres 16, 2026-09-15): the
  resulting schema has none of these columns, and
  `SELECT ... FROM information_schema.columns` returns an empty set for
  all four.

  Consequence of the gap this fixes: a genuinely fresh environment (disaster
  recovery, a new staging box, CI running migrations from scratch) would be
  silently missing all four columns, and the first query touching
  fcm_tokens.locale or *.timezone would crash with an undefined-column
  error -- `mix ecto.migrate` alone was not actually sufficient to
  reproduce the current production schema.

  `add_if_not_exists`/`remove_if_exists` make this migration safe to run
  against an environment where the columns already exist (PRIMARY, preprod
  -- this migration's `up` will no-op there and just record the version in
  schema_migrations, closing the tracking gap) AND against one where they
  don't (a fresh environment -- this migration will actually create them,
  matching what a fresh `mix ecto.migrate` should have done all along).

  Types/nullability match the live PRIMARY columns exactly (checked via
  information_schema.columns): all four are `text`, nullable, no default.
  """
  use Ecto.Migration

  def up do
    alter table(:fcm_tokens) do
      add_if_not_exists :locale, :text
    end

    alter table(:sentry_events) do
      add_if_not_exists :timezone, :text
    end

    alter table(:drives) do
      add_if_not_exists :timezone, :text
    end

    alter table(:charging_processes) do
      add_if_not_exists :timezone, :text
    end
  end

  def down do
    alter table(:fcm_tokens) do
      remove_if_exists :locale, :text
    end

    alter table(:sentry_events) do
      remove_if_exists :timezone, :text
    end

    alter table(:drives) do
      remove_if_exists :timezone, :text
    end

    alter table(:charging_processes) do
      remove_if_exists :timezone, :text
    end
  end
end
