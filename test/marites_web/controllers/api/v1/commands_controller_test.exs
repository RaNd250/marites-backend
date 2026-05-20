defmodule MaritesWeb.API.V1.CommandsControllerTest do
  use MaritesWeb.ConnCase

  alias Marites.{Repo, Auth.JWT}
  alias Marites.Accounts.User
  alias Marites.Log.Car

  defp authed_conn(user) do
    {:ok, token} = JWT.generate_access_token(user)
    build_conn() |> put_req_header("authorization", "Bearer #{token}")
  end

  defp insert_user!(email) do
    Repo.insert!(%User{email: email, active: true, admin: false})
  end

  defp insert_car!(user_id) do
    n = System.unique_integer([:positive])
    Repo.insert!(%Car{user_id: user_id, vid: n, eid: n, vin: "VIN#{n}", name: "Car", model: "3"})
  end

  test "returns 503 when user has no Api process running" do
    user = insert_user!("cmd@test.com")
    car = insert_car!(user.id)

    resp =
      authed_conn(user)
      |> post(~p"/api/v1/vehicles/#{car.id}/commands/sentry_on")

    assert json_response(resp, 503)["error"] == "not_signed_in"
  end

  test "returns 404 when car belongs to another user" do
    user_a = insert_user!("cmd_a@test.com")
    user_b = insert_user!("cmd_b@test.com")
    car_b = insert_car!(user_b.id)

    resp =
      authed_conn(user_a)
      |> post(~p"/api/v1/vehicles/#{car_b.id}/commands/sentry_on")

    assert json_response(resp, 404)["error"] == "car not found"
  end

  test "returns 400 for unknown command" do
    user = insert_user!("cmd_bad@test.com")
    resp = authed_conn(user) |> post(~p"/api/v1/vehicles/1/commands/launch_rocket")
    assert json_response(resp, 400)["error"] == "unknown command"
  end
end
