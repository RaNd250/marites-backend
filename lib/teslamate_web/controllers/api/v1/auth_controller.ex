defmodule TeslaMateWeb.API.V1.AuthController do
  use TeslaMateWeb, :controller

  alias TeslaMate.Accounts
  alias TeslaMate.Auth.JWT

  def register(conn, %{"email" => email, "password" => password, "invite_code" => invite_code}) do
    case Accounts.register_user(email, password, invite_code) do
      {:ok, user} ->
        {:ok, access_token} = JWT.generate_access_token(user)
        {:ok, refresh_token} = Accounts.create_refresh_token(user.id)

        conn
        |> put_status(:created)
        |> json(%{
          access_token: access_token,
          refresh_token: refresh_token,
          user: %{id: user.id, email: user.email, admin: user.admin}
        })

      {:error, :invalid_invite} ->
        conn |> put_status(422) |> json(%{error: "Invalid or already-used invite code"})

      {:error, %Ecto.Changeset{} = cs} ->
        errors = Ecto.Changeset.traverse_errors(cs, fn {msg, _} -> msg end)
        conn |> put_status(422) |> json(%{error: errors})
    end
  end

  def register(conn, _), do: conn |> put_status(400) |> json(%{error: "email, password and invite_code required"})

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate(email, password) do
      {:ok, user} ->
        {:ok, access_token} = JWT.generate_access_token(user)
        {:ok, refresh_token} = Accounts.create_refresh_token(user.id)

        json(conn, %{
          access_token: access_token,
          refresh_token: refresh_token,
          user: %{id: user.id, email: user.email, admin: user.admin}
        })

      {:error, :invalid_credentials} ->
        conn |> put_status(401) |> json(%{error: "Invalid email or password"})

      {:error, :account_inactive} ->
        conn |> put_status(403) |> json(%{error: "Account has been deactivated"})
    end
  end

  def login(conn, _), do: conn |> put_status(400) |> json(%{error: "email and password required"})

  def refresh(conn, %{"refresh_token" => raw_token}) do
    case Accounts.use_refresh_token(raw_token) do
      {:ok, user_id} ->
        user = Accounts.get_user(user_id)
        {:ok, access_token} = JWT.generate_access_token(user)
        {:ok, new_refresh} = Accounts.create_refresh_token(user_id)

        json(conn, %{
          access_token: access_token,
          refresh_token: new_refresh,
          user: %{id: user.id, email: user.email, admin: user.admin}
        })

      {:error, reason} ->
        conn |> put_status(401) |> json(%{error: to_string(reason)})
    end
  end

  def refresh(conn, _), do: conn |> put_status(400) |> json(%{error: "refresh_token required"})

  def logout(conn, %{"refresh_token" => raw_token}) do
    Accounts.revoke_refresh_token(raw_token)
    json(conn, %{ok: true})
  end

  def logout(conn, _), do: json(conn, %{ok: true})
end
