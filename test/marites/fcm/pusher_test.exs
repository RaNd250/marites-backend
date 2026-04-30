defmodule Marites.FCM.PusherTest do
  use ExUnit.Case, async: true

  alias Marites.FCM.Pusher
  alias Marites.Vehicles.Vehicle.Summary

  test "drive_started? detects P→D transition" do
    prev = %{shift_state: "P"}
    curr = %Summary{shift_state: "D"}
    assert Pusher.drive_started?(prev, curr) == true
  end

  test "drive_started? detects nil→R" do
    prev = %{shift_state: nil}
    curr = %Summary{shift_state: "R"}
    assert Pusher.drive_started?(prev, curr) == true
  end

  test "drive_started? ignores D→P" do
    prev = %{shift_state: "D"}
    curr = %Summary{shift_state: "P"}
    assert Pusher.drive_started?(prev, curr) == false
  end

  test "drive_started? ignores nil→nil" do
    prev = %{shift_state: nil}
    curr = %Summary{shift_state: nil}
    assert Pusher.drive_started?(prev, curr) == false
  end
end
