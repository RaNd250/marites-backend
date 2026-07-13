defmodule MaritesWeb.SignInLiveTest do
  use MaritesWeb.ConnCase

  # Token sign-in is handled by marites-api since the service split; the
  # engine page is a form shell. This guards against template regressions
  # like the dangling Vault call that 500ed /sign_in (b4f3868b).
  test "renders the sign-in page", %{conn: conn} do
    assert {:ok, view, html} = live(conn, "/sign_in")
    assert html =~ "Access Token"
    assert render(view) =~ "Refresh Token"
  end
end
