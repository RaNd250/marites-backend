defmodule Marites.AlarmResponder do
  use GenServer
  require Logger

  alias Marites.{Repo, Api, AlarmResponse.Settings}
  alias Marites.Vehicles.Vehicle.Summary
  alias Marites.Log.Car
  import Ecto.Query

  # car_states: %{car_id => %{sentry_mode_active: bool | nil}}
  defstruct car_states: %{}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    car_ids = Repo.all(from c in Car, select: c.id)

    for car_id <- car_ids do
      :ok = Phoenix.PubSub.subscribe(Marites.PubSub, "Marites.Vehicles.Vehicle/summary/#{car_id}")
    end

    Logger.info("AlarmResponder started, subscribed to #{length(car_ids)} car(s)")
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_info(%Summary{car: %Car{id: car_id}} = summary, state) do
    prev = get_in(state.car_states, [car_id, :sentry_mode_active])
    curr = summary.sentry_mode_active

    if prev != true and curr == true do
      trigger_alarm_response(car_id)
    end

    updated = Map.put(state.car_states, car_id, %{sentry_mode_active: curr})
    {:noreply, %{state | car_states: updated}}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp trigger_alarm_response(car_id) do
    case Repo.one(from c in Car, where: c.id == ^car_id, select: {c.user_id, c.vin}) do
      {user_id, vin} when not is_nil(user_id) and not is_nil(vin) ->
        prefs = Settings.get(user_id)

        Task.start(fn ->
          if prefs.honk_on_alarm do
            case Api.run_command(Marites.Api, vin, "honk_horn", %{}) do
              {:ok, _}     -> Logger.info("AlarmResponder: honked for car #{car_id}")
              {:error, r}  -> Logger.error("AlarmResponder: honk failed: #{inspect(r)}")
            end
          end

          if prefs.flash_on_alarm do
            case Api.run_command(Marites.Api, vin, "flash_lights", %{}) do
              {:ok, _}     -> Logger.info("AlarmResponder: flashed lights for car #{car_id}")
              {:error, r}  -> Logger.error("AlarmResponder: flash failed: #{inspect(r)}")
            end
          end
        end)

      _ ->
        Logger.warning("AlarmResponder: no user/vin for car #{car_id}, skipping")
    end
  end
end
