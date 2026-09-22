defmodule Marites.Repo.Migrations.AlarmResponseSettingsPerCar do
  use Ecto.Migration

  # Per-car alarm response settings: PK moves from (user_id) to (user_id, car_id)
  # so honk/flash/boombox can be enabled for one vehicle only.
  #
  # Every step is guarded/idempotent because:
  # - boombox_* are marites-api runtime columns (added by its boot-time
  #   ensure_schema) that do NOT exist on a bare CI database, and
  # - the same block is mirrored in the API's ensure_schema (the engine and API
  #   deploy jobs run in parallel), so either side may have run it already.

  def up do
    # Regularize API-owned columns so the backfill below can copy them.
    execute "ALTER TABLE alarm_response_settings ADD COLUMN IF NOT EXISTS boombox_on_alarm boolean DEFAULT false"
    execute "ALTER TABLE alarm_response_settings ADD COLUMN IF NOT EXISTS boombox_sound integer DEFAULT 0"
    execute "ALTER TABLE alarm_response_settings ADD COLUMN IF NOT EXISTS car_id integer"

    # Drop the single-column PK so per-car rows can coexist.
    execute """
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'alarm_response_settings'::regclass
          AND contype = 'p' AND array_length(conkey, 1) = 1
      ) THEN
        ALTER TABLE alarm_response_settings DROP CONSTRAINT alarm_response_settings_pkey;
      END IF;
    END $$;
    """

    # Expand each legacy per-user row into one row per car the user owns or has
    # been granted access to (car_access is an API-owned table that may not
    # exist on a bare CI database), preserving the old all-cars behavior.
    execute """
    DO $$
    BEGIN
      IF to_regclass('public.car_access') IS NOT NULL THEN
        INSERT INTO alarm_response_settings
          (user_id, car_id, honk_on_alarm, flash_on_alarm, boombox_on_alarm, boombox_sound, inserted_at, updated_at)
        SELECT s.user_id, uc.car_id, s.honk_on_alarm, s.flash_on_alarm, s.boombox_on_alarm, s.boombox_sound, s.inserted_at, s.updated_at
        FROM alarm_response_settings s
        JOIN (
          SELECT user_id, id AS car_id FROM cars WHERE user_id IS NOT NULL
          UNION
          SELECT user_id, car_id FROM car_access
        ) uc ON uc.user_id = s.user_id
        WHERE s.car_id IS NULL;
      ELSE
        INSERT INTO alarm_response_settings
          (user_id, car_id, honk_on_alarm, flash_on_alarm, boombox_on_alarm, boombox_sound, inserted_at, updated_at)
        SELECT s.user_id, c.id, s.honk_on_alarm, s.flash_on_alarm, s.boombox_on_alarm, s.boombox_sound, s.inserted_at, s.updated_at
        FROM alarm_response_settings s
        JOIN cars c ON c.user_id = s.user_id
        WHERE s.car_id IS NULL;
      END IF;
    END $$;
    """

    # Users with settings but no cars: nothing to scope to; defaults apply.
    execute "DELETE FROM alarm_response_settings WHERE car_id IS NULL"

    execute """
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'alarm_response_settings'::regclass AND contype = 'p'
      ) THEN
        ALTER TABLE alarm_response_settings ADD PRIMARY KEY (user_id, car_id);
      END IF;
    END $$;
    """
  end

  def down do
    # Collapse per-car rows back to one per-user row (logical OR of toggles).
    execute """
    CREATE TEMP TABLE ars_collapsed AS
    SELECT user_id,
           bool_or(honk_on_alarm)    AS honk_on_alarm,
           bool_or(flash_on_alarm)   AS flash_on_alarm,
           bool_or(boombox_on_alarm) AS boombox_on_alarm,
           max(boombox_sound)        AS boombox_sound,
           min(inserted_at)          AS inserted_at,
           max(updated_at)           AS updated_at
    FROM alarm_response_settings
    GROUP BY user_id
    """

    execute "DELETE FROM alarm_response_settings"
    execute "ALTER TABLE alarm_response_settings DROP CONSTRAINT alarm_response_settings_pkey"
    execute "ALTER TABLE alarm_response_settings DROP COLUMN car_id"

    execute """
    INSERT INTO alarm_response_settings
      (user_id, honk_on_alarm, flash_on_alarm, boombox_on_alarm, boombox_sound, inserted_at, updated_at)
    SELECT user_id, honk_on_alarm, flash_on_alarm, boombox_on_alarm, boombox_sound, inserted_at, updated_at
    FROM ars_collapsed
    """

    execute "ALTER TABLE alarm_response_settings ADD PRIMARY KEY (user_id)"
    execute "DROP TABLE ars_collapsed"
  end
end
