defmodule MaritesWeb.API.V1.AuthControllerTest do
  use MaritesWeb.ConnCase

  alias Marites.Accounts

  describe "POST /api/v1/auth/register" do
    test "returns 400 when invite_code missing and open registration is off" do
      Application.put_env(:marites, :open_registration, false)

      resp =
        build_conn()
        |> post(~p"/api/v1/auth/register", %{email: "new@test.com", password: "hunter2hunter2"})

      assert json_response(resp, 400)["error"] =~ "invite_code"

      Application.delete_env(:marites, :open_registration)
    end

    test "registers without invite_code when open registration is on" do
      Application.put_env(:marites, :open_registration, true)

      resp =
        build_conn()
        |> post(~p"/api/v1/auth/register", %{email: "open@test.com", password: "hunter2hunter2"})

      assert %{"access_token" => _, "refresh_token" => _, "user" => %{"email" => "open@test.com"}} =
               json_response(resp, 201)

      Application.delete_env(:marites, :open_registration)
    end

    test "POST /api/v1/auth/login succeeds with correct credentials" do
      Application.put_env(:marites, :open_registration, true)

      {:ok, _} =
        Accounts.register_user("login@test.com", "hunter2hunter2", nil)

      Application.delete_env(:marites, :open_registration)

      resp =
        build_conn()
        |> post(~p"/api/v1/auth/login", %{email: "login@test.com", password: "hunter2hunter2"})

      assert %{"access_token" => _, "refresh_token" => _} = json_response(resp, 200)
    end
  end
end
