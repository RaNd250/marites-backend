defmodule Marites.Locations do
  @moduledoc """
  The Locations context.
  """

  require Logger

  import Ecto.Query, warn: false
  import Marites.CustomExpressions

  alias __MODULE__.{Address, Geocoder, GeoFence}
  alias Marites.Log.{Drive, ChargingProcess, Position}
  alias Marites.Settings.GlobalSettings
  alias Marites.{Repo, Settings}

  ## Address

  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @geocoder (case Mix.env() do
               :test -> GeocoderMock
               _ -> Geocoder
             end)

  def find_address(%{latitude: lat, longitude: lng}) do
    %GlobalSettings{language: lang} = Settings.get_global_settings!()

    case @geocoder.reverse_lookup(lat, lng, lang) do
      {:ok, %{osm_id: id, osm_type: type} = attrs} ->
        case Repo.get_by(Address, osm_id: id, osm_type: type) do
          %Address{} = address -> {:ok, address}
          nil -> create_address(attrs)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def refresh_addresses(lang) do
    Address
    |> Repo.all()
    |> Enum.chunk_every(50)
    |> Enum.with_index()
    |> Enum.each(fn {addresses, i} ->
      if i > 0, do: Process.sleep(1500)

      {:ok, attrs} = @geocoder.details(addresses, lang)

      addresses
      |> merge_addresses(attrs)
      |> Enum.each(fn
        {%Address{osm_type: "unknown"}, _attrs} ->
          :ignore

        {%Address{} = address, attrs} when is_map(attrs) ->
          attrs =
            Map.take(attrs, [
              :city,
              :country,
              :county,
              :display_name,
              :neighbourhood,
              :state,
              :state_district
            ])

          {:ok, _} = update_address(address, attrs)

        {%Address{osm_id: id, osm_type: type} = address, nil} ->
          case Geocoder.reverse_lookup(address.latitude, address.longitude, lang) do
            {:ok, %{osm_id: ^id, osm_type: ^type} = attrs} ->
              attrs =
                Map.take(attrs, [
                  :city,
                  :country,
                  :county,
                  :display_name,
                  :neighbourhood,
                  :state,
                  :state_district
                ])

              {:ok, _} = update_address(address, attrs)

            {:ok, attrs} ->
              Logger.warning("""
              Address does not match! Skipping …

                osm_id: #{id} -> #{attrs[:osm_id]}
                osm_type: #{type} -> #{attrs[:osm_type]}

              """)
          end

          Process.sleep(1500)
      end)
    end)
  rescue
    e in MatchError ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      {:error, with({:error, reason} <- e.term, do: reason)}
  end

  defp merge_addresses(addresses, attrs) do
    addresses =
      Enum.reduce(addresses, %{}, fn %Address{osm_id: id, osm_type: type} = address, acc ->
        Map.put(acc, {type, id}, {address, nil})
      end)

    attrs
    |> Enum.reduce(addresses, fn %{osm_id: id, osm_type: type} = attrs, acc ->
      Map.update!(acc, {type, id}, fn {address, nil} -> {address, attrs} end)
    end)
    |> Map.values()
  end

  # positions.latitude/longitude are Cloak-encrypted (opaque bytea to
  # Postgres) since the encryption-at-rest migration — this used to be one
  # raw SQL UPDATE...FROM per module, doing the whole "find rows near this
  # geofence, then re-pick each one's globally-nearest geofence" dance with
  # ll_to_earth/earth_distance directly against positions.latitude/longitude.
  # That's no longer possible in SQL (the column is opaque bytes to
  # Postgres), so this now: 1) fetches candidate rows' positions through
  # Ecto (transparently decrypted), 2) filters to ones within this
  # geofence's radius in Elixir, 3) for each, re-picks the globally-nearest
  # geofence (excluding except_id) the same way, 4) writes the result back
  # with a plain per-row update_all. N+1 on the writes, but this only runs
  # on admin geofence create/update/delete — not a hot path.
  defp apply_geofence(%GeoFence{latitude: lat, longitude: lng, radius: r}, opts \\ []) do
    except_id = Keyword.get(opts, :except) || -1
    center = {to_float(lat), to_float(lng)}
    radius = to_float(r) || 0.0

    reassign_nearby_positions(Drive, :start_position_id, :start_geofence_id, center, radius, except_id)
    reassign_nearby_positions(Drive, :end_position_id, :end_geofence_id, center, radius, except_id)
    reassign_nearby_positions(ChargingProcess, :position_id, :geofence_id, center, radius, except_id)

    :ok
  end

  defp reassign_nearby_positions(module, position_field, geofence_field, center, radius, except_id) do
    candidates =
      from(m in module,
        join: p in Position, on: field(m, ^position_field) == p.id,
        select: {m.id, p.latitude, p.longitude}
      )
      |> Repo.all()
      |> Enum.filter(fn {_id, plat, plng} ->
        plat != nil and plng != nil and
          distance_m(center, {to_float(plat), to_float(plng)}) < radius
      end)

    if candidates != [] do
      other_geofences =
        from(g in GeoFence,
          where: g.id != ^except_id,
          select: %{id: g.id, latitude: g.latitude, longitude: g.longitude, radius: g.radius}
        )
        |> Repo.all()

      Enum.each(candidates, fn {id, plat, plng} ->
        new_geofence_id =
          nearest_geofence_id(other_geofences, {to_float(plat), to_float(plng)})

        from(m in module, where: m.id == ^id)
        |> Repo.update_all(set: [{geofence_field, new_geofence_id}])
      end)
    end
  end

  defp nearest_geofence_id(geofences, point) do
    geofences
    |> Enum.map(fn g ->
      {g.id, distance_m(point, {to_float(g.latitude), to_float(g.longitude)}), to_float(g.radius) || 0.0}
    end)
    |> Enum.filter(fn {_id, d, r} -> d < r end)
    |> Enum.min_by(fn {_id, d, _r} -> d end, fn -> nil end)
    |> case do
      {id, _d, _r} -> id
      nil -> nil
    end
  end

  @doc "Haversine distance in meters between two {lat, lng} float tuples."
  def distance_m({lat1, lon1}, {lat2, lon2}) do
    r = 6_371_000.0
    dlat = deg2rad(lat2 - lat1)
    dlon = deg2rad(lon2 - lon1)

    a =
      :math.sin(dlat / 2) * :math.sin(dlat / 2) +
        :math.cos(deg2rad(lat1)) * :math.cos(deg2rad(lat2)) *
          :math.sin(dlon / 2) * :math.sin(dlon / 2)

    2 * r * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
  end

  defp deg2rad(d), do: d * :math.pi() / 180.0

  defp to_float(nil), do: nil
  defp to_float(%Decimal{} = d), do: Decimal.to_float(d)
  defp to_float(n) when is_number(n), do: n / 1

  ## GeoFence

  def list_geofences do
    GeoFence
    |> order_by([g], fragment("? COLLATE \"C\" ASC", g.name))
    |> Repo.all()
  end

  def get_geofence!(id) do
    Repo.get!(GeoFence, id)
  end

  def find_geofence(%{latitude: _, longitude: _} = point) do
    GeoFence
    |> select([:id, :name])
    |> where([geofence], within_geofence?(point, geofence, :left))
    |> order_by([geofence], asc: distance(geofence, point))
    |> limit(1)
    |> Repo.one()
  end

  def create_geofence(attrs) do
    Repo.transaction(fn ->
      with {:ok, geofence} <- %GeoFence{} |> GeoFence.changeset(attrs) |> Repo.insert(),
           :ok <- apply_geofence(geofence) do
        geofence
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  def update_geofence(%GeoFence{id: id} = geofence, attrs) do
    Repo.transaction(fn ->
      with :ok <- apply_geofence(geofence, except: id),
           {:ok, geofence} <- geofence |> GeoFence.changeset(attrs) |> Repo.update(),
           :ok <- apply_geofence(geofence) do
        geofence
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  def delete_geofence(%GeoFence{id: id} = geofence) do
    Repo.transaction(fn ->
      with :ok <- apply_geofence(geofence, except: id),
           {:ok, geofence} <- Repo.delete(geofence) do
        geofence
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  def change_geofence(%GeoFence{} = geofence, attrs \\ %{}) do
    GeoFence.changeset(geofence, attrs)
  end

  def count_charging_processes_without_costs(%{latitude: lat, longitude: lng, radius: radius}) do
    center = {to_float(lat), to_float(lng)}
    radius = to_float(radius) || 0.0

    # positions.latitude/longitude are Cloak-encrypted (opaque bytea to
    # Postgres) — can't feed them into SQL-side ll_to_earth/earth_distance
    # (that's what within_geofence?(:right) used to do here). Fetch the
    # already-decrypted position through Ecto instead and do the same
    # Haversine-radius check in Elixir, matching the marites-api precedent
    # (MaritesAPI.ChargeClassifier.distance_m/2).
    from(c in ChargingProcess,
      join: p in assoc(c, :position),
      where: is_nil(c.cost),
      select: {c.id, p.latitude, p.longitude}
    )
    |> Repo.all()
    |> Enum.count(fn {_id, plat, plng} ->
      plat != nil and plng != nil and
        distance_m(center, {to_float(plat), to_float(plng)}) < radius
    end)
  end

  def calculate_charge_costs(%GeoFence{id: id}) do
    query = """
    UPDATE charging_processes cp
    SET cost = (
      SELECT
        CASE WHEN g.session_fee IS NULL AND g.cost_per_unit IS NULL THEN
               NULL
             WHEN g.billing_type = 'per_kwh' THEN
               COALESCE(g.session_fee, 0) +
               COALESCE(g.cost_per_unit * GREATEST(c.charge_energy_used, c.charge_energy_added), 0)
             WHEN g.billing_type = 'per_minute' THEN
               COALESCE(g.session_fee, 0) +
               COALESCE(g.cost_per_unit * c.duration_min, 0)
        END
      FROM charging_processes c
      JOIN geofences g ON g.id = c.geofence_id
      WHERE cp.id = c.id
    )
    WHERE cp.geofence_id = $1 AND cp.cost IS NULL;
    """

    with {:ok, %Postgrex.Result{num_rows: _}} <- Repo.query(query, [id]) do
      :ok
    end
  end
end
