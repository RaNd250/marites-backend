defmodule TeslaMateWeb.TeslaOAuthController do
  use TeslaMateWeb, :controller

  alias TeslaMate.{Accounts, Api}
  alias TeslaMate.Auth.{JWT, Tokens}

  @scope "openid email offline_access vehicle_device_data vehicle_cmds vehicle_charging_cmds"

  def authorize(conn, _params) do
    code_verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    code_challenge = :crypto.hash(:sha256, code_verifier) |> Base.url_encode64(padding: false)
    state = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

    conn =
      conn
      |> put_session(:code_verifier, code_verifier)
      |> put_session(:oauth_state, state)

    auth_host = System.get_env("TESLA_AUTH_HOST", "https://auth.tesla.com")
    auth_path = System.get_env("TESLA_AUTH_PATH", "/oauth2/v3")
    client_id = System.get_env("TESLA_AUTH_CLIENT_ID")

    params = URI.encode_query(%{
      client_id: client_id,
      redirect_uri: callback_uri(),
      response_type: "code",
      scope: @scope,
      code_challenge: code_challenge,
      code_challenge_method: "S256",
      state: state
    })

    redirect(conn, external: "#{auth_host}#{auth_path}/authorize?#{params}")
  end

  def callback(conn, %{"code" => code, "state" => state}) do
    stored_state = get_session(conn, :oauth_state)
    code_verifier = get_session(conn, :code_verifier)

    conn =
      conn
      |> delete_session(:oauth_state)
      |> delete_session(:code_verifier)

    if state != stored_state do
      conn |> put_status(400) |> text("Invalid state — possible CSRF attempt")
    else
      with {:ok, %{access_token: access, refresh_token: refresh}} <- exchange_code(code, code_verifier),
           {:ok, userinfo} <- get_userinfo(access),
           {:ok, email} <- extract_email(userinfo),
           :ok <- store_in_teslamate(access, refresh),
           {:ok, user} <- Accounts.find_or_create_by_email(email),
           {:ok, access_tok} <- JWT.generate_access_token(user),
           {:ok, refresh_tok} <- Accounts.create_refresh_token(user.id) do
        params = URI.encode_query(%{teslami_token: access_tok, teslami_refresh: refresh_tok})
        redirect(conn, external: "/?#{params}")
      else
        {:error, reason} ->
          conn |> put_status(502) |> text("Sign-in failed: #{inspect(reason)}")
        _ ->
          conn |> put_status(502) |> text("Sign-in failed: unexpected error")
      end
    end
  end

  def callback(conn, _params) do
    conn |> put_status(400) |> text("Missing code or state parameter")
  end

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
         |> Finch.request(TeslaMate.HTTP) do
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
         |> Finch.request(TeslaMate.HTTP) do
      {:ok, %{status: 200, body: raw}} -> {:ok, Jason.decode!(raw)}
      {:ok, %{status: status}} -> {:error, "userinfo #{status}"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_email(%{"email" => email}) when is_binary(email) and email != "", do: {:ok, email}
  defp extract_email(_), do: {:error, "email not found in Tesla userinfo"}

  defp store_in_teslamate(access, refresh) do
    tokens = %Tokens{access: access, refresh: refresh}
    case Api.sign_in(tokens) do
      :ok -> :ok
      {:error, :already_signed_in} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp callback_uri do
    System.get_env("APP_URL", "https://teslami.vitaldata.gr") <> "/auth/tesla/callback"
  end
end
