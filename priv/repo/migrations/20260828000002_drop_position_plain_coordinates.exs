defmodule Marites.Repo.Migrations.DropPositionPlainCoordinates do
  use Ecto.Migration

  @moduledoc """
  Step 2/2 of encrypting positions.latitude/longitude at rest — see
  20260828000001_add_encrypted_position_columns.exs. Only deployed after
  `Marites.Release.encrypt_positions/0` was run manually and its output
  confirmed 0 remaining rows with latitude_plain IS NOT NULL AND latitude IS
  NULL. Drops the now-redundant plaintext columns and restores the original
  NOT NULL constraint on the encrypted columns.
  """

  def up do
    alter table(:positions) do
      modify :latitude, :binary, null: false
      modify :longitude, :binary, null: false
    end

    alter table(:positions) do
      remove_if_exists :latitude_plain, :numeric
      remove_if_exists :longitude_plain, :numeric
    end
  end

  def down do
    alter table(:positions) do
      add_if_not_exists :latitude_plain, :numeric
      add_if_not_exists :longitude_plain, :numeric
    end

    alter table(:positions) do
      modify :latitude, :binary, null: true
      modify :longitude, :binary, null: true
    end
  end
end
