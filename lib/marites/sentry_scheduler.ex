defmodule Marites.SentryScheduler do
  use GenServer
  require Logger

  alias Marites.{SentrySchedule, Api}
  alias Marites.Log.Car
  alias Marites.Repo
  import Ecto.Query

  @interval :timer.minutes(1)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule_check()
    Logger.info("SentryScheduler started")
    {:ok, %{}}
  end

  @impl true
  def handle_info(:check, state) do
    check_schedules()
    schedule_check()
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp schedule_check, do: Process.send_after(self(), :check, @interval)

  defp check_schedules do
    now = DateTime.utc_now()
    hour = now.hour
    minute = now.minute
    day_of_week = Date.day_of_week(DateTime.to_date(now)) - 1

    schedules_with_eid =
      Repo.all(
        from s in SentrySchedule,
          where: s.enabled == true and s.day_of_week == ^day_of_week,
          join: c in Car, on: c.id == s.car_id,
          select: {s, c.eid}
      )

    for {schedule, eid} <- schedules_with_eid do
      cond do
        hour == schedule.on_hour and minute == schedule.on_minute ->
          Logger.info("Scheduler: enabling sentry for car #{schedule.car_id}")
          Api.run_command(eid, "set_sentry_mode", %{"on" => true})

        hour == schedule.off_hour and minute == schedule.off_minute ->
          Logger.info("Scheduler: disabling sentry for car #{schedule.car_id}")
          Api.run_command(eid, "set_sentry_mode", %{"on" => false})

        true ->
          :ok
      end
    end
  end
end
