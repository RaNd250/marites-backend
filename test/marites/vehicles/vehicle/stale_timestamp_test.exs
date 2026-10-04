defmodule Marites.Vehicles.Vehicle.StaleTimestampTest do
  # Upstream TeslaMate #5692 (#5684): after asleep/offline a payload can carry a
  # drive_state timestamp older than the open `states` row. Dating the new state
  # with it would close that row with end_date < start_date (positive_duration)
  # and crash the vehicle process on every poll. It must be dated now instead.
  use Marites.VehicleCase, async: false

  @tag :capture_log
  test "after a restart, a payload older than the open state row is dated now",
       %{test: name} do
    # The process restarts (e.g. a deploy) while the car is asleep: the open
    # `asleep` row began a minute ago, there is no previous response to compare
    # with, and the car reports a drive_state timestamp from an hour ago.
    row_start = DateTime.utc_now() |> DateTime.add(-60, :second) |> DateTime.truncate(:millisecond)
    stale_ts = DateTime.utc_now() |> DateTime.add(-3600, :second) |> DateTime.to_unix(:millisecond)
    stale = online_event(drive_state: %{timestamp: stale_ts, latitude: 0.0, longitude: 0.0})

    events = [{:ok, stale}, {:ok, stale}, fn -> Process.sleep(10_000) end]

    :ok =
      start_vehicle(name, events,
        current_state: %Marites.Log.State{state: :asleep, start_date: row_start}
      )

    # [] -> Log.start_state dates the row now. Before the fix this was
    # date: <an hour before row_start>, which positive_duration rejects and
    # which crashed the vehicle process on every poll.
    assert_receive {:start_state, _car, :online, []}, 2_000
  end

  @tag :capture_log
  test "a current online payload is still dated with its own timestamp", %{test: name} do
    now_ts = DateTime.utc_now() |> DateTime.add(5, :second) |> DateTime.to_unix(:millisecond)

    events = [
      # An online poll reads the API twice (vehicle, then vehicle data), so
      # online events come in pairs, as in vehicle_test.exs.
      {:ok, online_event()},
      {:ok, online_event()},
      {:ok, %TeslaApi.Vehicle{state: "asleep"}},
      {:ok, %TeslaApi.Vehicle{state: "asleep"}},
      {:ok, online_event(drive_state: %{timestamp: now_ts, latitude: 0.0, longitude: 0.0})},
      {:ok, online_event(drive_state: %{timestamp: now_ts, latitude: 0.0, longitude: 0.0})},
      fn -> Process.sleep(10_000) end
    ]

    :ok = start_vehicle(name, events)

    date = DateTime.from_unix!(now_ts, :millisecond)
    assert_receive {:start_state, car_id, :online, date: _}, 600
    assert_receive {:start_state, ^car_id, :asleep, []}, 2_000
    assert_receive {:start_state, ^car_id, :online, date: ^date}, 5_000
  end
end
