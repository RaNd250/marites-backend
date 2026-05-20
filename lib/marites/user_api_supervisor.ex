defmodule Marites.UserApiSupervisor do
  use DynamicSupervisor

  require Logger

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc "Start a per-user Api process. Idempotent — returns {:ok, pid} if already running."
  def start_for_user(user_id) do
    spec = {Marites.Api, name: Marites.ApiRegistry.via(user_id), user_id: user_id}

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  @doc "True if a process is running for this user_id."
  def running?(user_id) do
    case Registry.lookup(Marites.ApiRegistry, user_id) do
      [{_pid, _}] -> true
      [] -> false
    end
  end
end
