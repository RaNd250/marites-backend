defmodule Marites.UserApiLoader do
  use GenServer

  require Logger
  import Ecto.Query

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Run after the supervisor tree is up, not inline in init
    send(self(), :load)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:load, state) do
    user_ids =
      Marites.Repo.all(
        from t in Marites.Accounts.TeslaToken,
          select: t.user_id
      )

    Logger.info("UserApiLoader: starting Api processes for #{length(user_ids)} user(s)")

    Enum.each(user_ids, fn user_id ->
      case Marites.UserApiSupervisor.start_for_user(user_id) do
        {:ok, _pid} ->
          Logger.info("UserApiLoader: started Api for user #{user_id}")

        {:error, reason} ->
          Logger.warning("UserApiLoader: failed to start Api for user #{user_id}: #{inspect(reason)}")
      end
    end)

    {:noreply, state}
  end
end
