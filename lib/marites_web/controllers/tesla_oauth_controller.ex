defmodule MaritesWeb.TeslaOAuthController do
  use MaritesWeb, :controller

  alias Marites.{Accounts, Api}
  alias Marites.Auth.{JWT, Tokens}

  @scope "openid email offline_access vehicle_device_data vehicle_cmds vehicle_charging_cmds vehicle_location"
  @state_ttl_seconds 600

  def authorize(conn, _params) do
    code_verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    code_challenge = :crypto.hash(:sha256, code_verifier) |> Base.url_encode64(padding: false)

    # Embed code_verifier in a signed state param — no session needed
    state = build_state(code_verifier)

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
         :ok <- store_in_Marites(access, refresh),
         {:ok, user} <- Accounts.find_or_create_by_email(email),
         {:ok, access_tok} <- JWT.generate_access_token(user),
         {:ok, refresh_tok} <- Accounts.create_refresh_token(user.id) do
      link_cars_to_user(user.id)
      params = URI.encode_query(%{marites_token: access_tok, marites_refresh: refresh_tok})
      redirect(conn, external: "/?#{params}")
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

  defp build_state(code_verifier) do
    payload = Jason.encode!(%{
      "cv" => code_verifier,
      "exp" => System.os_time(:second) + @state_ttl_seconds
    })
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

  defp hmac_sign(data) do
    secret = Application.fetch_env!(:Marites, :jwt_secret)
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

  # Link all Marites cars that have no user_id to this user.
  # Marites creates cars asynchronously after sign_in, so we run the update
  # immediately (for existing cars) and again after a short delay (for new ones).
  defp link_cars_to_user(user_id) do
    alias Marites.{Repo, Log.Car}
    # Marites is single-tenant — all cars belong to whoever just signed in via Tesla OAuth.
    # Update every car unconditionally, and again after a short delay for newly created ones.
    Repo.update_all(Car, set: [user_id: user_id])
    Task.start(fn ->
      Process.sleep(8_000)
      Repo.update_all(Car, set: [user_id: user_id])
    end)
  end

  defp store_in_Marites(access, refresh) do
    tokens = %Tokens{access: access, refresh: refresh}
    # Always replace the token — user explicitly went through OAuth to update scopes
    Api.sign_out()
    case Api.sign_in(tokens) do
      :ok -> :ok
      {:error, :already_signed_in} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp callback_uri do
    System.get_env("APP_URL", "https://app.marit.es") <> "/auth/tesla/callback"
  end
end
