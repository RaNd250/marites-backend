defmodule Marites.Api do
  # Tesla vehicle polling now lives in marites-api (separate service).
  # This stub returns :not_signed_in so the engine's state machines degrade
  # gracefully to Fleet Telemetry-only mode (no REST polling).

  def get_vehicle(_id), do: {:error, :not_signed_in}
  def get_vehicle_with_state(_id), do: {:error, :not_signed_in}
  def get_vehicle_sentry_state(_id), do: {:error, :not_signed_in}
  def signed_in?, do: false
  def sign_in(_tokens), do: :ok
  def sign_out, do: :ok
end
