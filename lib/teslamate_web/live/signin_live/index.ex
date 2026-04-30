defmodule TeslaMateWeb.SignInLive.Index do
  use TeslaMateWeb, :live_view

  import Core.Dependency, only: [call: 3]
  alias TeslaMate.{Auth, Api, Accounts}
  alias TeslaMate.Auth.JWT
  alias TeslaApi.Auth, as: TeslaAuth

  on_mount {TeslaMateWeb.InitAssigns, :locale}

  @impl true
  def mount(_params, _session, socket) do
    assigns = %{
      api: get_api(socket),
      page_title: gettext("Sign in"),
      error: nil,
      task: nil,
      changeset: Auth.change_tokens(),
      token: System.get_env("TOKEN", ""),
      provider: System.get_env("TESLA_AUTH_HOST", "https://auth.tesla.com")
    }

    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("validate", %{"tokens" => tokens}, socket) do
    changeset =
      tokens
      |> Auth.change_tokens()
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset, error: nil)}
  end

  def handle_event("sign_in", _, socket) do
    tokens = Ecto.Changeset.apply_changes(socket.assigns.changeset)

    task =
      Task.async(fn ->
        call(socket.assigns.api, :sign_in, [tokens])
      end)

    {:noreply, assign(socket, task: task)}
  end

  @impl true
  def handle_info({ref, result}, %{assigns: %{task: %Task{ref: ref}}} = socket) do
    Process.demonitor(ref, [:flush])

    case result do
      :ok ->
        Process.sleep(250)
        {:noreply, issue_marites_session(socket)}

      {:error, %TeslaApi.Error{} = e} ->
        message =
          case e.reason do
            :token_refresh ->
              gettext("Tokens are invalid")

            :account_locked ->
              gettext(
                "Your Tesla account is locked due to too many failed sign in attempts. " <>
                  "To unlock your account, reset your password"
              )

            _ ->
              Exception.message(e)
          end

        {:noreply, assign(socket, error: message, task: nil)}
    end
  end

  defp get_api(socket) do
    case get_connect_params(socket) do
      %{api: api} -> api
      _ -> Api
    end
  end

  defp issue_marites_session(socket) do
    with {:ok, auth}        <- Api.get_auth(),
         {:ok, userinfo}    <- TeslaAuth.get_userinfo(auth),
         email              = Map.get(userinfo, "email") || Map.get(userinfo, :email),
         true               <- is_binary(email),
         {:ok, user}        <- Accounts.find_or_create_by_email(email),
         {:ok, access_tok}  <- JWT.generate_access_token(user),
         {:ok, refresh_tok} <- Accounts.create_refresh_token(user.id) do
      params = URI.encode_query(%{marites_token: access_tok, marites_refresh: refresh_tok})
      redirect(socket, external: "/?#{params}")
    else
      _ ->
        # Fallback: Tesla auth succeeded but we couldn't issue a Marit.es JWT — go to legacy UI
        socket
        |> put_flash(:success, gettext("Signed in successfully"))
        |> redirect(to: Routes.car_path(socket, :index))
    end
  end
end
