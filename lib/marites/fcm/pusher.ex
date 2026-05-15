defmodule Marites.FCM.Pusher do
  use GenServer
  require Logger

  alias Marites.{Repo, FCM.TokenStore, Notifications.Settings}
  alias Marites.Vehicles.Vehicle.Summary
  alias Marites.Log.Car
  import Ecto.Query

  @google_token_url "https://oauth2.googleapis.com/token"
  @fcm_scope "https://www.googleapis.com/auth/firebase.messaging"

  defstruct car_states: %{}, access_token: nil, token_expires_at: 0

  # car_states: %{car_id => %{sentry_mode: bool | nil, sentry_mode_active: bool | nil, charging_state: string | nil, shift_state: string | nil}}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    car_ids = Repo.all(from c in Car, select: c.id)

    for car_id <- car_ids do
      :ok = Phoenix.PubSub.subscribe(Marites.PubSub, "Marites.Vehicles.Vehicle/summary/#{car_id}")
    end

    Logger.info("FCM.Pusher started, subscribed to #{length(car_ids)} car(s)")
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_info(%Summary{car: %Car{id: car_id}} = summary, state) do
    prev = Map.get(state.car_states, car_id, %{sentry_mode: nil, sentry_mode_active: nil, charging_state: nil, shift_state: nil})
    events = detect_events(prev, summary)

    new_state =
      if events == [] do
        state
      else
        case maybe_refresh_token(state) do
          {:ok, refreshed} ->
            push_events(events, summary, refreshed)
            refreshed

          {:error, reason} ->
            Logger.error("FCM.Pusher auth failed: #{inspect(reason)}")
            state
        end
      end

    updated = Map.put(new_state.car_states, car_id, %{
      sentry_mode: summary.sentry_mode,
      sentry_mode_active: summary.sentry_mode_active,
      charging_state: summary.charging_state,
      shift_state: summary.shift_state
    })

    {:noreply, %{new_state | car_states: updated}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  # --- Event detection ---

  defp detect_events(prev, summary) do
    []
    |> check_drive(prev, summary)
    |> check_sentry(prev, summary)
    |> check_sentry_alarm(prev, summary)
    |> check_charge(prev, summary)
  end

  defp check_drive(events, prev, summary) do
    if drive_started?(prev, summary), do: [:drive_started | events], else: events
  end

  def drive_started?(%{shift_state: prev}, %Summary{shift_state: curr}) do
    driving = ["D", "R", "N"]
    curr in driving and prev not in driving
  end

  def drive_started?(_, _), do: false

  defp check_sentry(events, %{sentry_mode: prev}, %Summary{sentry_mode: curr}) do
    cond do
      # Only fire on false->true transition; nil (first message) does not trigger
      prev == false and curr == true -> [:sentry_activated | events]
      prev == true and curr != true -> [:sentry_deactivated | events]
      true -> events
    end
  end

  defp check_sentry_alarm(events, %{sentry_mode_active: prev}, %Summary{sentry_mode_active: curr}) do
    if prev == false and curr == true do
      [:sentry_alarm | events]
    else
      events
    end
  end

  defp check_charge(events, %{charging_state: prev}, %Summary{charging_state: curr}) do
    cond do
      # prev must be known (not nil) to avoid spurious trigger on first message
      prev != nil and prev != "Charging" and curr == "Charging" -> [:charge_started | events]
      prev == "Charging" and curr == "Complete" -> [:charge_complete | events]
      true -> events
    end
  end

  # --- Push notifications ---

  @core_only_events ~w(drive_started charge_started charge_complete)a

  defp push_events(events, summary, state) do
    user_id = Repo.one(from c in Car, where: c.id == ^summary.car.id, select: c.user_id)

    if user_id != nil do
      for event <- events do
        {enabled, delivery} = Settings.get_delivery(user_id, to_string(event))

        if enabled and delivery == "push" do
          edition = if event in @core_only_events, do: "core", else: nil
          tokens = TokenStore.tokens_for_user(user_id, edition)

          if tokens != [] do
            {title, body} = notification_text(event, summary)
            send_to_all(tokens, event, title, body, summary, state.access_token)
          end
        end
      end
    end
  end

  defp send_to_all(tokens, event, title, body, summary, access_token) do
    project_id = System.get_env("FIREBASE_PROJECT_ID", "")
    url = "https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send"

    for token <- tokens do
      base_data = %{
        "event"        => to_string(event),
        "type"         => to_string(event),
        "display_name" => summary.display_name || "Marit.es",
        "lat"          => to_string(summary.latitude),
        "lng"          => to_string(summary.longitude)
      }

      data = if event == :sentry_alarm,
        do: Map.put(base_data, "deep_link", "tesla_app"),
        else: base_data

      payload = Jason.encode!(%{
        "message" => %{
          "token"        => token,
          "notification" => %{"title" => title, "body" => body},
          "data"         => data
        }
      })

      headers = [
        {"authorization", "Bearer #{access_token}"},
        {"content-type", "application/json"}
      ]

      case Finch.request(Finch.build(:post, url, headers, payload), Marites.HTTP) do
        {:ok, %{status: 200}} ->
          Logger.debug("FCM push sent: #{event}")

        {:ok, %{status: status, body: resp}} ->
          Logger.warning("FCM push #{event} failed #{status}: #{resp}")

        {:error, reason} ->
          Logger.error("FCM push #{event} error: #{inspect(reason)}")
      end
    end
  end

  defp notification_text(:drive_started, summary) do
    name = summary.display_name || "Marit.es"
    {"Marit.es", "#{name}: Ξεκίνησε οδήγηση"}
  end

  defp notification_text(:sentry_activated, summary) do
    name = summary.display_name || "Your Tesla"
    {"Sentry Activated", "#{name} detected motion nearby"}
  end

  defp notification_text(:sentry_deactivated, summary) do
    name = summary.display_name || "Your Tesla"
    {"Sentry Deactivated", "#{name} is now quiet"}
  end

  defp notification_text(:charge_started, summary) do
    name = summary.display_name || "Your Tesla"
    {"Charging Started", "#{name} has started charging"}
  end

  defp notification_text(:charge_complete, summary) do
    name = summary.display_name || "Your Tesla"
    pct = summary.battery_level || 0
    {"Charging Complete", "#{name} is charged to #{pct}%"}
  end

  defp notification_text(:sentry_alarm, summary) do
    name = summary.display_name || "Your Tesla"
    {"Alarm Triggered", "#{name} detected someone nearby"}
  end

  defp notification_text(event, summary) do
    {to_string(event), summary.display_name || "Marit.es"}
  end

  # --- Google OAuth2 token management ---
  # Tokens are cached in state and refreshed 60s before expiry.

  defp maybe_refresh_token(%__MODULE__{access_token: token, token_expires_at: exp} = state) do
    if token != nil and System.system_time(:second) < exp - 60 do
      {:ok, state}
    else
      case fetch_access_token() do
        {:ok, {new_token, new_exp}} ->
          {:ok, %{state | access_token: new_token, token_expires_at: new_exp}}

        {:error, _} = err ->
          err
      end
    end
  end

  defp fetch_access_token do
    with {:ok, sa} <- load_service_account(),
         {:ok, jwt} <- sign_jwt(sa),
         {:ok, result} <- exchange_for_token(jwt) do
      {:ok, result}
    end
  end

  defp load_service_account do
    case System.get_env("FIREBASE_SERVICE_ACCOUNT_JSON") do
      nil -> {:error, :no_service_account_json}
      json -> Jason.decode(json)
    end
  end

  defp sign_jwt(%{"private_key" => pem, "client_email" => email}) do
    now = System.system_time(:second)

    header =
      %{"alg" => "RS256", "typ" => "JWT"}
      |> Jason.encode!()
      |> Base.url_encode64(padding: false)

    claims =
      %{
        "iss" => email,
        "scope" => @fcm_scope,
        "aud" => @google_token_url,
        "iat" => now,
        "exp" => now + 3600
      }
      |> Jason.encode!()
      |> Base.url_encode64(padding: false)

    signing_input = "#{header}.#{claims}"

    try do
      # pem_entry_decode handles both RSAPrivateKey and PKCS8 PrivateKeyInfo formats
      [entry] = :public_key.pem_decode(pem)
      private_key = :public_key.pem_entry_decode(entry)
      signature = :public_key.sign(signing_input, :sha256, private_key)
      {:ok, "#{signing_input}.#{Base.url_encode64(signature, padding: false)}"}
    rescue
      e -> {:error, {:jwt_sign_failed, Exception.message(e)}}
    end
  end

  defp exchange_for_token(jwt) do
    body = URI.encode_query(%{
      "grant_type" => "urn:ietf:params:oauth:grant-type:jwt-bearer",
      "assertion" => jwt
    })

    req = Finch.build(:post, @google_token_url, [{"content-type", "application/x-www-form-urlencoded"}], body)

    case Finch.request(req, Marites.HTTP) do
      {:ok, %{status: 200, body: resp_body}} ->
        %{"access_token" => token, "expires_in" => ttl} = Jason.decode!(resp_body)
        {:ok, {token, System.system_time(:second) + ttl}}

      {:ok, %{status: status, body: body}} ->
        {:error, "Token exchange failed #{status}: #{body}"}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
