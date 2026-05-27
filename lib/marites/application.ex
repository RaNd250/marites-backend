defmodule Marites.Application do
  use Application

  require Logger

  def start(_type, _args) do
    Logger.info("System Info: #{system_info()}")
    Logger.info("Version: #{Application.spec(:marites, :vsn) || "???"}")

    # Disable log entries
    :ok = :telemetry.detach({Phoenix.Logger, [:phoenix, :socket_connected]})
    :ok = :telemetry.detach({Phoenix.Logger, [:phoenix, :channel_joined]})

    Marites.DatabaseCheck.check_postgres_version()

    Supervisor.start_link(children(), strategy: :one_for_one, name: Marites.Supervisor)
  end

  defp children do
    mqtt_config = Application.get_env(:marites, :mqtt)

    case Application.get_env(:marites, :import_directory) do
      nil ->
        [
          Marites.Repo,
          {Finch, name: Marites.HTTP},
          Marites.Updater,
          {Phoenix.PubSub, name: Marites.PubSub},
          MaritesWeb.Endpoint,
          Marites.Terrain,
          Marites.Vehicles,
          if(mqtt_config != nil, do: {Marites.Mqtt, mqtt_config}),
          Marites.Repair
        ]
        |> Enum.reject(&is_nil/1)

      import_directory ->
        [
          Marites.Repo,
          {Finch, name: Marites.HTTP},
          Marites.Updater,
          {Phoenix.PubSub, name: Marites.PubSub},
          MaritesWeb.Endpoint,
          {Marites.Terrain, disabled: true},
          {Marites.Repair, limit: 250},
          {Marites.Import, directory: import_directory}
        ]
    end
  end

  defp system_info do
    case otp_release() do
      vsn when vsn <= 23 -> "Erlang/OTP #{vsn}"
      vsn -> "Erlang/OTP #{vsn} (#{emu_flavor()})"
    end
  end

  defp otp_release do
    :erlang.system_info(:otp_release) |> to_string() |> String.to_integer()
  rescue
    _ -> nil
  end

  defp emu_flavor do
    :erlang.system_info(:emu_flavor)
  rescue
    ArgumentError -> nil
  end

  def config_change(changed, _new, removed) do
    MaritesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
