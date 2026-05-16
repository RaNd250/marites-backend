defmodule Marites.Accounts do
  import Ecto.Query
  alias Marites.Repo
  alias Marites.Accounts.{User, InviteCode, RefreshToken, TeslaToken}

  # ---- Users ----

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

  def find_or_create_by_email(email) do
    email = String.downcase(email)
    case Repo.get_by(User, email: email) do
      %User{} = user ->
        {:ok, user}
      nil ->
        Repo.insert(User.oauth_changeset(%User{}, %{email: email}))
    end
  end

  def authenticate(email, password) do
    user = get_user_by_email(email)

    cond do
      user == nil ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}

      not user.active ->
        {:error, :account_inactive}

      Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      true ->
        {:error, :invalid_credentials}
    end
  end

  def register_user(email, password, invite_code_str) do
    Repo.transaction(fn ->
      invite = Repo.one(from i in InviteCode, where: i.code == ^invite_code_str and is_nil(i.used_by))

      unless invite do
        Repo.rollback(:invalid_invite)
      end

      case Repo.insert(User.registration_changeset(%User{}, %{email: String.downcase(email), password: password})) do
        {:ok, user} ->
          now = DateTime.utc_now() |> DateTime.truncate(:second)
          Repo.update!(Ecto.Changeset.change(invite, used_by: user.id, used_at: now))
          user

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def list_users do
    Repo.all(from u in User, order_by: [asc: u.inserted_at])
  end

  def revoke_user(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:error, :not_found}
      user -> Repo.update(Ecto.Changeset.change(user, active: false))
    end
  end

  def delete_user_data(user_id) do
    Repo.transaction(fn ->
      Repo.delete_all(from t in TeslaToken, where: t.user_id == ^user_id)
      Repo.delete_all(from r in RefreshToken, where: r.user_id == ^user_id)
      Repo.delete_all(
        from c in Marites.Log.Car, where: c.user_id == ^user_id
      )
      :ok
    end)
  end

  def delete_account(user_id) do
    Repo.transaction(fn ->
      {:ok, _} = delete_user_data(user_id)
      Repo.delete_all(from u in User, where: u.id == ^user_id)
      :ok
    end)
  end

  # ---- Invite Codes ----

  def create_invite_code(admin_user_id) do
    code = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

    Repo.insert(InviteCode.changeset(%InviteCode{}, %{
      code: code,
      created_by: admin_user_id
    }))
  end

  def list_invite_codes(admin_user_id) do
    Repo.all(from i in InviteCode, where: i.created_by == ^admin_user_id, order_by: [desc: i.inserted_at])
  end

  # ---- Refresh Tokens ----

  def create_refresh_token(user_id) do
    raw_token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    token_hash = :crypto.hash(:sha256, raw_token) |> Base.encode64()
    expires_at = DateTime.add(DateTime.utc_now(), 30 * 24 * 3600, :second) |> DateTime.truncate(:second)

    case Repo.insert(RefreshToken.changeset(%RefreshToken{}, %{
      user_id: user_id,
      token_hash: token_hash,
      expires_at: expires_at
    })) do
      {:ok, _} -> {:ok, raw_token}
      err -> err
    end
  end

  def use_refresh_token(raw_token) do
    token_hash = :crypto.hash(:sha256, raw_token) |> Base.encode64()
    now = DateTime.utc_now()

    case Repo.get_by(RefreshToken, token_hash: token_hash) do
      nil ->
        {:error, :invalid}

      rt ->
        if DateTime.compare(rt.expires_at, now) == :lt do
          Repo.delete(rt)
          {:error, :expired}
        else
          Repo.delete(rt)
          {:ok, rt.user_id}
        end
    end
  end

  def revoke_refresh_token(raw_token) do
    token_hash = :crypto.hash(:sha256, raw_token) |> Base.encode64()
    Repo.delete_all(from r in RefreshToken, where: r.token_hash == ^token_hash)
    :ok
  end

  # ---- Tesla Tokens ----

  def get_tesla_token(user_id) do
    Repo.get_by(TeslaToken, user_id: user_id)
  end

  def upsert_tesla_token(user_id, refresh_token, access_token, expires_at) do
    attrs = %{
      user_id: user_id,
      encrypted_refresh_token: refresh_token,
      access_token: access_token,
      token_expires_at: expires_at
    }

    Repo.insert(
      TeslaToken.changeset(%TeslaToken{}, attrs),
      on_conflict: {:replace, [:encrypted_refresh_token, :access_token, :token_expires_at, :updated_at]},
      conflict_target: :user_id
    )
  end

  def delete_tesla_token(user_id) do
    Repo.delete_all(from t in TeslaToken, where: t.user_id == ^user_id)
    :ok
  end
end
