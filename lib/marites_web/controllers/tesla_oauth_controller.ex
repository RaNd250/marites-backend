defmodule MaritesWeb.TeslaOAuthController do
  use MaritesWeb, :controller

  alias Marites.{Accounts}
  alias Marites.Auth.JWT

  @scope "openid email offline_access vehicle_device_data vehicle_cmds vehicle_charging_cmds vehicle_location"
  @state_ttl_seconds 600

  def authorize(conn, params) do
    code_verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    code_challenge = :crypto.hash(:sha256, code_verifier) |> Base.url_encode64(padding: false)

    # Optional: mobile apps pass redirect_scheme=es.marit.lite://auth-callback
    # to receive tokens via a deep-link instead of the web redirect.
    redirect_scheme = Map.get(params, "redirect_scheme")
    state = build_state(code_verifier, redirect_scheme)

    auth_host = System.get_env("TESLA_AUTH_HOST", "https://auth.tesla.com")
    auth_path = System.get_env("TESLA_AUTH_PATH", "/oauth2/v3")
    client_id = System.get_env("TESLA_AUTH_CLIENT_ID")

    params = URI.encode_query(%{
      client_id: client_id,
      redirect_uri: callback_uri(),
      response_type: "code",
      scope: @scope,
      prompt: "consent",
      code_challenge: code_challenge,
      code_challenge_method: "S256",
      state: state
    })

    redirect(conn, external: "#{auth_host}#{auth_path}/authorize?#{params}")
  end

  def callback(conn, %{"code" => code, "state" => state}) do
    with {:ok, code_verifier} <- verify_state(state),
         {:ok, %{access_token: access, refresh_token: refresh}} <- exchange_code(code, code_verifier),
         {:ok, userinfo} <- get_userinfo(access),
         {:ok, email} <- extract_email(userinfo),
         {:ok, user} <- Accounts.find_or_create_by_email(email),
         :ok <- start_user_api(user.id, access, refresh),
         :ok <- claim_vehicles_by_vin(user.id, access),
         {:ok, access_tok} <- JWT.generate_access_token(user),
         {:ok, refresh_tok} <- Accounts.create_refresh_token(user.id) do
      query = URI.encode_query(%{marites_token: access_tok, marites_refresh: refresh_tok})

      redirect_target =
        case verify_state_scheme(state) do
          {:ok, scheme} when is_binary(scheme) -> "#{scheme}?#{query}"
          _ -> "/?#{query}"
        end

      redirect(conn, external: redirect_target)
    else
      {:error, :invalid_state} ->
        conn |> put_status(400) |> text("Invalid or expired state parameter — please try signing in again")

      {:error, reason} ->
        require Logger
        Logger.error("Tesla OAuth callback failed: #{inspect(reason)}")
        conn |> put_status(502) |> text("Sign-in failed: #{inspect(reason)}")

      other ->
        require Logger
        Logger.error("Tesla OAuth callback unexpected: #{inspect(other)}")
        conn |> put_status(502) |> text("Sign-in failed: unexpected error")
    end
  end

  def callback(conn, _params) do
    conn |> put_status(400) |> text("Missing code or state parameter")
  end

  # --- State: signed JSON containing code_verifier + expiry ---

  defp build_state(code_verifier, redirect_scheme \\ nil) do
    payload =
      %{"cv" => code_verifier, "exp" => System.os_time(:second) + @state_ttl_seconds}
      |> then(fn p -> if redirect_scheme, do: Map.put(p, "rs", redirect_scheme), else: p end)
      |> Jason.encode!()
    sig = hmac_sign(payload)
    Base.url_encode64(payload, padding: false) <> "." <> sig
  end

  defp verify_state(state) do
    with [encoded, sig] <- String.split(state, ".", parts: 2),
         {:ok, payload_json} <- Base.url_decode64(encoded, padding: false),
         expected = hmac_sign(payload_json),
         true <- Plug.Crypto.secure_compare(sig, expected),
         {:ok, %{"cv" => cv, "exp" => exp}} <- Jason.decode(payload_json),
         true <- System.os_time(:second) < exp do
      {:ok, cv}
    else
      _ -> {:error, :invalid_state}
    end
  end

  # Returns {:ok, scheme} if the state contains a valid mobile redirect scheme,
  # {:ok, nil} otherwise. Separate from verify_state to avoid breaking the main with-chain.
  defp verify_state_scheme(state) do
    with [encoded, _sig] <- String.split(state, ".", parts: 2),
         {:ok, payload_json} <- Base.url_decode64(encoded, padding: false),
         {:ok, payload} <- Jason.decode(payload_json) do
      {:ok, Map.get(payload, "rs")}
    else
      _ -> {:ok, nil}
    end
  end

  defp hmac_sign(data) do
    secret = Application.fetch_env!(:marites, :jwt_secret)
    :crypto.mac(:hmac, :sha256, secret, data) |> Base.url_encode64(padding: false)
  end

  # --- Token exchange & userinfo ---

  defp exchange_code(code, code_verifier) do
    auth_host = System.get_env("TESLA_AUTH_HOST", "https://auth.tesla.com")
    auth_path = System.get_env("TESLA_AUTH_PATH", "/oauth2/v3")
    client_id = System.get_env("TESLA_AUTH_CLIENT_ID")
    client_secret = System.get_env("TESLA_CLIENT_SECRET")

    body = URI.encode_query(%{
      grant_type: "authorization_code",
      client_id: client_id,
      client_secret: client_secret,
      code: code,
      redirect_uri: callback_uri(),
      code_verifier: code_verifier
    })

    case Finch.build(:post, "#{auth_host}#{auth_path}/token",
           [{"content-type", "application/x-www-form-urlencoded"}], body)
         |> Finch.request(Marites.HTTP) do
      {:ok, %{status: 200, body: raw}} ->
        data = Jason.decode!(raw)
        {:ok, %{access_token: data["access_token"], refresh_token: data["refresh_token"]}}
      {:ok, %{status: status, body: raw}} ->
        {:error, "token exchange #{status}: #{raw}"}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_userinfo(access_token) do
    auth_host = System.get_env("TESLA_AUTH_HOST", "https://auth.tesla.com")
    auth_path = System.get_env("TESLA_AUTH_PATH", "/oauth2/v3")

    case Finch.build(:get, "#{auth_host}#{auth_path}/userinfo",
           [{"authorization", "Bearer #{access_token}"}])
         |> Finch.request(Marites.HTTP) do
      {:ok, %{status: 200, body: raw}} -> {:ok, Jason.decode!(raw)}
      {:ok, %{status: status}} -> {:error, "userinfo #{status}"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_email(%{"email" => email}) when is_binary(email) and email != "", do: {:ok, email}
  defp extract_email(_), do: {:error, "email not found in Tesla userinfo"}

  # Upsert cars by VIN for this user. Safe for multi-tenant: only touches
  # cars whose VINs belong to the Tesla account that just authenticated.
  defp claim_vehicles_by_vin(user_id, access_token) do
    alias Marites.Log.Car
    auth = %TeslaApi.Auth{token: access_token}

    case TeslaApi.Vehicle.list(auth) do
      {:ok, vehicles} ->
        Enum.each(vehicles, fn v ->
          Marites.Repo.insert!(
            %Car{
              user_id: user_id,
              vin: v.vin,
              vid: v.vehicle_id,
              eid: v.id,
              name: v.display_name || "Tesla",
              model: nil
            },
            on_conflict: [
              set: [user_id: user_id, eid: v.id, vid: v.vehicle_id, name: v.display_name || "Tesla"]
            ],
            conflict_target: :vin
          )
        end)

        :ok

      {:error, reason} ->
        require Logger
        Logger.warning("claim_vehicles_by_vin failed for user #{user_id}: #{inspect(reason)}")
        :ok
    end
  end

  # Store tokens in DB and start (or restart) the per-user Api process.
  defp start_user_api(user_id, access, refresh) do
    expires_at =
      DateTime.add(DateTime.utc_now(), 8 * 3600, :second)
      |> DateTime.truncate(:second)

    case Marites.Accounts.upsert_tesla_token(user_id, refresh, access, expires_at) do
      {:ok, _} ->
        :ok

      {:error, reason} ->
        require Logger
        Logger.error("Failed to upsert Tesla token for user #{user_id}: #{inspect(reason)}")
        :ok
    end

    case Marites.UserApiSupervisor.start_for_user(user_id) do
      {:ok, _pid} ->
        :ok

      {:error, reason} ->
        require Logger
        Logger.error("Failed to start Api for user #{user_id}: #{inspect(reason)}")
        :ok
    end
  end

  defp callback_uri do
    System.get_env("APP_URL", "https://app.marit.es") <> "/auth/tesla/callback"
  end
end
