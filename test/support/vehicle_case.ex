defmodule Marites.VehicleCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Marites.VehicleCase
    end
  end

  setup tags do
    Marites.SandboxOwner.start!(tags)
  end

  alias Marites.Vehicles.Vehicle
  alias Marites.Settings.CarSettings
  alias Marites.Log.{Car, Update}
  alias TeslaApi.Vehicle.State

  def start_vehicle(name, events, opts \\ []) when length(events) > 0 do
    mock_log? = Keyword.get(opts, :log, true)
    last = Keyword.get(opts, :last_update, %Update{version: "9999.99.99.0 lasjas234"})

    log_name = :"log_#{name}"
    api_name = :"api_#{name}"
    settings_name = :"settings_#{name}"
    locations_name = :"locations_#{name}"
    vehicles_name = :"vehicles_#{name}"
    pubsub_name = :"pubsub_#{name}"

    {:ok, _pid} = start_supervised({LogMock, name: log_name, pid: self(), last_update: last})
    {:ok, _pid} = start_supervised({ApiMock, name: api_name, events: events, pid: self()})
    {:ok, _pid} = start_supervised({SettingsMock, name: settings_name, pid: self()})
    {:ok, _pid} = start_supervised({VehiclesMock, name: vehicles_name, pid: self()})
    {:ok, _pid} = start_supervised({PubSubMock, name: pubsub_name, pid: self()})
    {:ok, _pid} = start_supervised({LocationsMock, name: locations_name, pid: self()})

    opts =
      Keyword.put_new_lazy(opts, :car, fn ->
        settings =
          Keyword.get(opts, :settings, %{})
          |> Map.put_new(:req_no_shift_state_reading, false)
          |> Map.put_new(:req_no_temp_reading, false)
          |> Map.put_new(:req_not_unlocked, true)

        %Car{
          id: :rand.uniform(65536),
          eid: 0,
          vid: 1000,
          vin: "1000",
          model: "3",
          settings: struct(CarSettings, settings)
        }
      end)

    deps =
      [
        name: name,
        deps_log: {LogMock, log_name},
        deps_api: {ApiMock, api_name},
        deps_settings: {SettingsMock, settings_name},
        deps_locations: {LocationsMock, locations_name},
        deps_vehicles: {VehiclesMock, vehicles_name},
        deps_pubsub: {PubSubMock, pubsub_name}
      ]
      |> Enum.filter(fn
        {:deps_log, _} -> mock_log?
        _ -> true
      end)

    {:ok, _pid} = start_supervised({Vehicle, Keyword.merge(opts, deps)})

    assert_receive {SettingsMock, :subscribe_to_changes}

    :ok
  end

  # Covers three cases the same way: no :timestamp key at all (e.g. the
  # default drive_state: %{latitude: 0.0, longitude: 0.0} below has none),
  # an explicit 0, or an explicit nil. All three previously left the field
  # unset/invalid on the built struct, which crashed downstream in
  # Vehicle.create_position/2 with DateTime.from_unix(nil, ...). Using
  # Map.update/4 with a default handles "key absent" and "key present"
  # in one place instead of needing a separate clause per case.
  defp normalize_ts(map, now) do
    Map.update(map, :timestamp, now, fn
      0 -> now
      nil -> now
      ts -> ts
    end)
  end

  def online_event(opts \\ []) do
    now = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    drive_state =
      Keyword.get(opts, :drive_state, %{latitude: 0.0, longitude: 0.0})
      |> normalize_ts(now)

    charge_state = Keyword.get(opts, :charge_state, %{}) |> normalize_ts(now)
    climate_state = Keyword.get(opts, :climate_state, %{}) |> normalize_ts(now)
    vehicle_state = Keyword.get(opts, :vehicle_state, %{}) |> normalize_ts(now)
    vehicle_config = Keyword.get(opts, :vehicle_config, %{}) |> normalize_ts(now)

    %TeslaApi.Vehicle{
      state: "online",
      display_name: Keyword.get(opts, :display_name),
      charge_state: struct(State.Charge, charge_state),
      drive_state: struct(State.Drive, drive_state),
      climate_state: struct(State.Climate, climate_state),
      vehicle_state: struct(State.VehicleState, vehicle_state),
      vehicle_config: struct(State.VehicleConfig, vehicle_config)
    }
  end

  def drive_event(ts, shift_state, speed_mph) do
    online_event(
      drive_state: %{
        timestamp: ts,
        latitude: 0.1,
        longitude: 0.1,
        shift_state: shift_state,
        speed: speed_mph
      }
    )
  end

  def charging_event(ts, charging_state, charge_energy_added, opts \\ []) do
    range = Keyword.get(opts, :range)

    online_event(
      charge_state: %{
        timestamp: ts,
        charging_state: charging_state,
        charge_energy_added: charge_energy_added,
        ideal_battery_range: range,
        battery_range: range
      },
      drive_state: %{timestamp: ts, latitude: 0.0, longitude: 0.0}
    )
  end

  def update_event(ts, state, car_version, opts \\ []) do
    alias TeslaApi.Vehicle.State.VehicleState.SoftwareUpdate

    update_version = Keyword.get(opts, :update_version)

    online_event(
      vehicle_state: %{
        timestamp: ts,
        car_version: car_version,
        software_update: %SoftwareUpdate{
          expected_duration_sec: 2700,
          status: state,
          version: update_version
        }
      },
      drive_state: %{timestamp: ts, latitude: 0.0, longitude: 0.0}
    )
  end
end
