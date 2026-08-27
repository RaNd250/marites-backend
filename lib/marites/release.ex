defmodule Marites.Release do
  @app :marites

  import Ecto.Query
  alias Marites.Repo

  def migrate do
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    for r <- repos(), r == repo do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    end
  end

  def seconds_since_last_migration do
    Repo.one(
      from m in "schema_migrations",
        select: fragment("EXTRACT(EPOCH FROM age(NOW(), ?::timestamp))::BIGINT", m.inserted_at),
        order_by: [desc: m.inserted_at],
        limit: 1
    )
  end

  @doc """
  One-off data backfill for the positions.latitude/longitude encryption
  migration (see 20260828000001_add_encrypted_position_columns.exs). Not run
  automatically by `migrate/0` — invoke manually once, after that migration
  has deployed, via:

      docker compose exec marites bin/marites eval "Marites.Release.encrypt_positions()"

  Idempotent and safe to re-run: each pass only touches rows where the new
  encrypted column is still NULL, so an interrupted run just picks up where
  it left off. Prints progress; returns the total row count encrypted.

  Deliberately starts only Repo + Vault (like `migrate/0` starts only Repo)
  instead of the full OTP application — running this via a full
  `Application.ensure_all_started(:marites)` would try to bind the Endpoint
  port and start Vehicles/Mqtt/Terrain a second time in the same container,
  colliding with the already-running production process.
  """
  def encrypt_positions(batch_size \\ 2000) do
    Application.ensure_all_started(:ssl)
    Application.load(@app)

    {:ok, vault_pid} = Marites.Vault.start_link([])

    {:ok, total, _} =
      Ecto.Migrator.with_repo(Repo, fn _repo ->
        do_encrypt_batches(batch_size, 0)
      end)

    IO.puts("encrypt_positions: done, #{total} row(s) encrypted")

    GenServer.stop(vault_pid)
    total
  end

  defp do_encrypt_batches(batch_size, total) do
    {:ok, %{rows: rows}} =
      Ecto.Adapters.SQL.query(
        Repo,
        """
        SELECT id, latitude_plain, longitude_plain
        FROM positions
        WHERE latitude IS NULL AND latitude_plain IS NOT NULL
        ORDER BY id
        LIMIT $1
        """,
        [batch_size]
      )

    case rows do
      [] ->
        total

      _ ->
        Enum.each(rows, fn [id, lat, lng] ->
          {:ok, enc_lat} = Marites.Vault.Encrypted.Decimal.dump(lat)
          {:ok, enc_lng} = Marites.Vault.Encrypted.Decimal.dump(lng)

          Ecto.Adapters.SQL.query!(
            Repo,
            "UPDATE positions SET latitude = $1, longitude = $2 WHERE id = $3",
            [enc_lat, enc_lng, id]
          )
        end)

        new_total = total + length(rows)
        IO.puts("encrypt_positions: #{new_total} row(s) so far...")
        do_encrypt_batches(batch_size, new_total)
    end
  end

  defp repos do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
