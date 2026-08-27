defmodule Marites.Repo.Migrations.AddEncryptedPositionColumns do
  use Ecto.Migration

  @moduledoc """
  Step 1/2 of encrypting positions.latitude/longitude at rest (Cloak.Ecto,
  AES-256-GCM — same mechanism as TeslaToken). Expand-migrate-contract:

    1. (this migration) rename the existing plaintext numeric columns out of
       the way, add new binary columns under the original names. From the
       moment this deploys, the app (Marites.Log.Position /
       MaritesAPI.Schemas.Position, both updated in the same commit) writes
       new positions as encrypted binary in latitude/longitude.
    2. Run `Marites.Release.encrypt_positions/0` once (manual, via
       `docker compose exec marites bin/marites eval
       "Marites.Release.encrypt_positions()"`) to backfill every existing row
       — encrypts latitude_plain/longitude_plain into latitude/longitude.
    3. A follow-up migration (pushed only after the backfill is verified
       complete — see AGENT/commit notes) drops latitude_plain/
       longitude_plain and sets latitude/longitude NOT NULL.

  Small table (~27k rows in prod as of 2026-08-28) — the backfill is a
  one-shot batched script, not something this migration does inline, so it
  never holds a long-running transaction or locks the table for longer than
  the rename+add (both instant, metadata-only operations).
  """

  def up do
    rename table(:positions), :latitude, to: :latitude_plain
    rename table(:positions), :longitude, to: :longitude_plain

    # latitude_plain/longitude_plain carried the original NOT NULL constraint
    # over from the rename. They must become nullable here: from this deploy
    # onward every new position insert (marites-api's Fleet Telemetry
    # consumer, via the updated Position schema) writes only the new
    # encrypted latitude/longitude columns below and never touches these
    # legacy ones again — a NOT NULL left in place would make every new
    # position insert fail. (Caught by the backend test suite's ImportTest
    # before this shipped: import inserts hit "null value in column
    # latitude_plain violates not-null constraint".)
    execute "ALTER TABLE positions ALTER COLUMN latitude_plain DROP NOT NULL"
    execute "ALTER TABLE positions ALTER COLUMN longitude_plain DROP NOT NULL"

    alter table(:positions) do
      add_if_not_exists :latitude, :binary
      add_if_not_exists :longitude, :binary
    end
  end

  def down do
    alter table(:positions) do
      remove_if_exists :latitude, :binary
      remove_if_exists :longitude, :binary
    end

    rename table(:positions), :latitude_plain, to: :latitude
    rename table(:positions), :longitude_plain, to: :longitude
  end
end
