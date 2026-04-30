defmodule Marites.SentryEvents do
  use GenServer
  require Logger

  alias Marites.{Repo, SentryEvent}
  alias Marites.Vehicles.Vehicle.Summary
  alias Marites.Log.Car
  import Ecto.Query

  defstruct car_states: %{}, active_events: %{}

  # car_states:    %{car_id => %{sentry_mode: bool | nil}}
  # active_events: %{car_id => sentry_event_db_id}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    car_ids = Repo.all(from c in Car, select: c.id)

    for car_id <- car_ids do
      :ok = Phoenix.PubSub.subscribe(Marites.PubSub, "Marites.Vehicles.Vehicle/summary/#{car_id}")
    end

    Logger.info("SentryEvents started, subscribed to #{length(car_ids)} car(s)")
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_info(%Summary{car: %Car{id: car_id}} = summary, state) do
    prev_sentry = get_in(state.car_states, [car_id, :sentry_mode])
    curr_sentry = summary.sentry_mode

    new_state =
      cond do
        prev_sentry == false and curr_sentry == true ->
          on_activated(state, car_id, summary)

        prev_sentry == true and curr_sentry != true ->
          on_deactivated(state, car_id)

        true ->
          state
      end

    updated = Map.put(new_state.car_states, car_id, %{sentry_mode: curr_sentry})
    {:noreply, %{new_state | car_states: updated}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  # --- Sentry activation: insert a new row ---

  defp on_activated(state, car_id, summary) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    address = if summary.geofence, do: summary.geofence.name, else: nil

    attrs = %{
      car_id: car_id,
      activated_at: now,
      start_lat: to_float(summary.latitude),
      start_lng: to_float(summary.longitude),
      address: address
    }

    case Repo.insert(SentryEvent.changeset(%SentryEvent{}, attrs)) do
      {:ok, event} ->
        Logger.info("Sentry activated: car #{car_id}, event #{event.id}")
        %{state | active_events: Map.put(state.active_events, car_id, event.id)}

      {:error, changeset} ->
        Logger.error("Sentry activate insert failed: #{inspect(changeset.errors)}")
        state
    end
  end

  # --- Sentry deactivation: update the open row ---

  defp on_deactivated(state, car_id) do
    case Map.get(state.active_events, car_id) do
      nil ->
        Logger.warning("Sentry deactivated for car #{car_id} but no open event tracked")
        state

      event_id ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        with %SentryEvent{} = event <- Repo.get(SentryEvent, event_id),
             duration <- DateTime.diff(now, event.activated_at),
             {:ok, _} <-
               Repo.update(SentryEvent.changeset(event, %{
                 deactivated_at: now,
                 duration_seconds: duration
               })) do
          Logger.info("Sentry deactivated: car #{car_id}, duration #{duration}s")
        else
          nil ->
            Logger.warning("Sentry event #{event_id} not found in DB")

          {:error, changeset} ->
            Logger.error("Sentry deactivate update failed: #{inspect(changeset.errors)}")
        end

        %{state | active_events: Map.delete(state.active_events, car_id)}
    end
  end

  defp to_float(nil), do: nil
  defp to_float(val) when is_float(val), do: val
  defp to_float(val) when is_integer(val), do: val * 1.0
  defp to_float(%Decimal{} = d), do: Decimal.to_float(d)
end
