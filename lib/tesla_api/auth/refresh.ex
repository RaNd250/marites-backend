defmodule TeslaApi.Auth.Refresh do
  import TeslaApi.Auth, only: [post: 2]

  alias TeslaApi.{Auth, Error}

  @web_client_id TeslaApi.Auth.web_client_id()

  # Fleet Auth is the new token refresh endpoint (auth.tesla.com deprecated Aug 2025)
  @fleet_auth_host "https://fleet-auth.prd.vn.cloud.tesla.com"
  @fleet_auth_path "/oauth2/v3"

  def refresh(%Auth{} = auth) do
    host = System.get_env("TESLA_FLEET_AUTH_HOST", @fleet_auth_host)
    path = System.get_env("TESLA_FLEET_AUTH_PATH", @fleet_auth_path)

    data =
      %{
        grant_type: "refresh_token",
        scope: "openid email offline_access vehicle_device_data vehicle_cmds vehicle_charging_cmds vehicle_location",
        client_id: System.get_env("TESLA_AUTH_CLIENT_ID", @web_client_id),
        refresh_token: auth.refresh_token
      }
      |> maybe_add_client_secret()

    case post("#{host}#{path}/token" <> System.get_env("TOKEN", ""), data) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        auth = %Auth{
          token: body["access_token"],
          type: body["token_type"],
          expires_in: body["expires_in"],
          refresh_token: body["refresh_token"],
          created_at: body["created_at"]
        }
        {:ok, auth}

      error ->
        Error.into(error, :token_refresh)
    end
  end

  defp maybe_add_client_secret(data) do
    case System.get_env("TESLA_CLIENT_SECRET") do
      secret when is_binary(secret) and secret != "" -> Map.put(data, :client_secret, secret)
      _ -> data
    end
  end
end
