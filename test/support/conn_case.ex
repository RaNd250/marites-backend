defmodule MaritesWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MaritesWeb.ConnCase

      alias MaritesWeb.Router.Helpers, as: Routes
      import Phoenix.LiveViewTest

      # The default endpoint for testing
      @endpoint MaritesWeb.Endpoint

      use MaritesWeb, :verified_routes
    end
  end

  setup tags do
    :ok = Marites.SandboxOwner.start!(tags)

    # Start the Endpoint manually since tests run with '--no-start'
    {:ok, _pid} = start_supervised(MaritesWeb.Endpoint)

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.assign(:signed_in?, !!tags[:signed_in])

    {:ok, conn: conn}
  end
end
