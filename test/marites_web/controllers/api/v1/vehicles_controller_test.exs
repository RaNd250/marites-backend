defmodule MaritesWeb.API.V1.VehiclesControllerTest do
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

  defp insert_car!(user_id, name) do
    n = System.unique_integer([:positive])
    Repo.insert!(%Car{
      user_id: user_id,
      vid: n,
      eid: n,
      vin: "VIN#{n}",
      name: name,
      model: "3"
    })
  end

  test "returns only the current user's cars" do
    user_a = insert_user!("a@test.com")
    user_b = insert_user!("b@test.com")
    car_a = insert_car!(user_a.id, "Car A")
    _car_b = insert_car!(user_b.id, "Car B")

    resp = authed_conn(user_a) |> get(~p"/api/v1/vehicles/status")
    body = json_response(resp, 200)
    assert length(body) == 1
    assert hd(body)["id"] == car_a.id
  end

  test "returns empty list when user has no cars" do
    user = insert_user!("nobody@test.com")
    resp = authed_conn(user) |> get(~p"/api/v1/vehicles/status")
    assert json_response(resp, 200) == []
  end

  test "returns 401 without auth" do
    resp = build_conn() |> get(~p"/api/v1/vehicles/status")
    assert json_response(resp, 401)
  end
end
