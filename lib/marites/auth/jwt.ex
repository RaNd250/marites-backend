defmodule Marites.Auth.JWT do
  use Joken.Config

  @access_token_ttl 15 * 60

  def token_config do
    default_claims(skip: [:aud, :iss, :jti, :nbf], default_exp: @access_token_ttl)
  end

  def generate_access_token(user) do
    extra = %{
      "user_id" => user.id,
      "email"   => user.email,
      "admin"   => user.admin
    }

    signer = signer()

    case generate_and_sign(extra, signer) do
      {:ok, token, _claims} -> {:ok, token}
      err -> err
    end
  end

  def verify_access_token(token) do
    signer = signer()

    case verify_and_validate(token, signer) do
      {:ok, claims} ->
        {:ok, %{
          id:    claims["user_id"],
          email: claims["email"],
          admin: claims["admin"]
        }}

      {:error, _} ->
        {:error, :invalid_token}
    end
  end

  defp signer do
    secret = Application.fetch_env!(:marites, :jwt_secret)
    Joken.Signer.create("HS256", secret)
  end
end
