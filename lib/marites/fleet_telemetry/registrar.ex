defmodule Marites.FleetTelemetry.Registrar do
  require Logger

  alias Marites.{Repo, Api}
  alias Marites.Log.Car
  import Ecto.Query

  @fields %{
    "Location"            => %{"interval_seconds" => 10},
    "VehicleSpeed"        => %{"interval_seconds" => 10, "minimum_delta" => 1.0},
    "Odometer"            => %{"interval_seconds" => 60, "minimum_delta" => 0.1},
    "Soc"                 => %{"interval_seconds" => 30, "minimum_delta" => 1.0},
    "DetailedChargeState" => %{"interval_seconds" => 10},
    "Gear"                => %{"interval_seconds" => 5},
    "SentryMode"          => %{"interval_seconds" => 10}
  }

  def register_all do
    cars = Repo.all(from c in Car, select: {c.vin, c.name})

    Enum.map(cars, fn {vin, name} ->
      result = register(vin)
      label = name || vin

      case result do
        {:ok, resp} ->
          Logger.info("Fleet telemetry registered for #{label}: #{inspect(resp)}")
        {:error, reason} ->
          Logger.error("Fleet telemetry registration failed for #{label}: #{inspect(reason)}")
      end

      {vin, result}
    end)
  end

  def register(vin) do
    hostname = System.get_env("FLEET_TELEMETRY_HOST", "app.marit.es")
    exp = System.system_time(:second) + 60 * 60 * 24 * 365 * 10

    config = %{
      "config" => %{
        "hostname"     => hostname,
        "port"         => 443,
        "fields"       => @fields,
        "alert_types"  => ["service_alert"],
        "exp"          => exp
      }
    }

    Api.register_fleet_telemetry(vin, config)
  end
end
