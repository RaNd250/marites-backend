# FIXME Workaround to apply the logger config when running the tests with
# "--no-start". This looks like a bug in Elixir v1.11.0
Application.stop(:logger)
Application.start(:logger)

Application.load(:marites)

for app <- Application.spec(:marites, :applications) do
  {:ok, _} = Application.ensure_all_started(app)
end

Marites.Repo.start_link()
Marites.Vault.start_link([])
Phoenix.PubSub.Supervisor.start_link(name: Marites.PubSub)

assert_timeout = String.to_integer(System.get_env("ELIXIR_ASSERT_TIMEOUT") || "300")
ExUnit.start(assert_receive_timeout: assert_timeout)
