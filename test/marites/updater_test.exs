defmodule Marites.UpdaterTest do
  use Marites.DataCase, async: true

  alias Marites.Updater
  import Mock

  defmodule HTTPMocck do
    def vsn(tag) do
      json(%{"tag_name" => tag, "prerelease" => false, "draft" => false})
    end

    def json(data) do
      response({:ok, %Tesla.Env{status: 200, body: data}})
    end

    def response(resp) do
      [
        {Tesla.Adapter.Finch, [],
         call: fn %Tesla.Env{} = env, _opts ->
           assert env.url ==
                    "https://api.github.com/repos/Marites-org/Marites/releases/latest"

           resp
         end}
      ]
    end
  end

  defp start_updater(name, version, opts \\ []) do
    id = Keyword.get(opts, :id, 0)

    start_supervised(
      {Updater, [name: :"updater#{id}_#{name}}", version: version, check_after: 0]},
      id: id
    )
  end

  test "informs if an update is available", %{test: name} do
    with_mocks HTTPMocck.vsn("v5.1.2") do
      ## current_version > new_version
      {:ok, pid} = start_updater(name, "5.1.3-dev", id: 0)
      Process.sleep(100)
      assert nil == Updater.get_update(pid)

      ## current_version == new_version
      {:ok, pid} = start_updater(name, "5.1.2", id: 1)
      Process.sleep(100)
      assert nil == Updater.get_update(pid)

      ## current_version < new_version
      {:ok, pid} = start_updater(name, "4.99.0", id: 2)
      # The release check runs in handle_continue; a fixed 100 ms sleep raced
      # it on a loaded CI box and blocked deploys. Poll for up to 2 s instead.
      assert "5.1.2" == wait_for_update(pid)
    end
  end

  test "returns early even though update check is still in progress", %{test: name} do
    with_mocks [{Tesla.Adapter.Finch, [], call: fn _, _ -> Process.sleep(1_000_000) end}] do
      {:ok, pid} = start_updater(name, "1.0.0")
      assert nil == Updater.get_update(pid)
    end
  end

  @tag :capture_log
  test "handles invalid tags", %{test: name} do
    with_mocks HTTPMocck.vsn("2.0.0") do
      {:ok, pid} = start_updater(name, "1.0.0")
      assert nil == Updater.get_update(pid)
    end
  end

  @tag :capture_log
  test "handles invalid json", %{test: name} do
    with_mocks HTTPMocck.json(%{"foo" => "bar"}) do
      {:ok, pid} = start_updater(name, "1.0.0")
      assert nil == Updater.get_update(pid)
    end
  end

  @tag :capture_log
  test "handles HTTP errors", %{test: name} do
    with_mocks HTTPMocck.response({:ok, %Tesla.Env{status: 404}}) do
      {:ok, pid} = start_updater(name, "1.0.0", id: 0)
      assert nil == Updater.get_update(pid)
    end

    with_mocks HTTPMocck.response({:error, :timeout}) do
      {:ok, pid} = start_updater(name, "1.0.0", id: 1)
      assert nil == Updater.get_update(pid)
    end
  end

  test "handles prereleases and drafts", %{test: name} do
    with_mocks HTTPMocck.json(%{"tag_name" => "v99.0.0", "prerelease" => true, "draft" => false}) do
      {:ok, pid} = start_updater(name, "1.0.0", id: 0)
      assert nil == Updater.get_update(pid)
    end

    with_mocks HTTPMocck.json(%{"tag_name" => "v99.0.0", "prerelease" => false, "draft" => true}) do
      {:ok, pid} = start_updater(name, "1.0.0", id: 1)
      assert nil == Updater.get_update(pid)
    end
  end

  defp wait_for_update(pid, tries \\ 40) do
    case Updater.get_update(pid) do
      nil when tries > 0 ->
        Process.sleep(50)
        wait_for_update(pid, tries - 1)

      result ->
        result
    end
  end
end
