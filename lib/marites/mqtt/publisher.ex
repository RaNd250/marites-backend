defmodule Marites.Mqtt.Publisher do
  use GenServer

  require Logger

  @name __MODULE__
  @timeout :timer.seconds(10)

  defstruct client_id: nil,
            refs: %{}

  alias __MODULE__, as: State

  # API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  def publish(topic, msg \\ nil, opts \\ []) do
    GenServer.call(@name, {:publish, topic, msg, opts}, @timeout)
  end

  # Callbacks

  @impl true
  def init(opts) do
    {:ok, %State{client_id: Keyword.fetch!(opts, :client_id)}}
  end

  @impl true
  def handle_call({:publish, topic, msg, opts}, from, %State{client_id: id, refs: refs} = state) do
    opts = Keyword.put_new(opts, :timeout, round(@timeout * 0.95))

    # A publish failure is a broker or connection problem, not a bug in this
    # process. Returning it lets the caller decide; matching on it would take
    # the Publisher down and, with it, every caller blocked in publish/3 -- and
    # would drop the refs of the QoS>0 publishes still awaiting acknowledgement.
    case Keyword.get(opts, :qos, 0) do
      0 ->
        case Tortoise311.publish(id, topic, msg, opts) do
          :ok ->
            {:reply, :ok, state}

          {:error, reason} = error ->
            Logger.warning("MQTT publish to #{topic} failed: #{inspect(reason)}")
            {:reply, error, state}
        end

      _ ->
        case Tortoise311.publish(id, topic, msg, opts) do
          {:ok, ref} ->
            {:noreply, %State{state | refs: Map.put(refs, ref, from)}}

          {:error, reason} = error ->
            Logger.warning("MQTT publish to #{topic} failed: #{inspect(reason)}")
            {:reply, error, state}
        end
    end
  end

  @impl true
  def handle_info({{Tortoise311, id}, ref, result}, %State{client_id: id, refs: refs} = state) do
    # An unknown ref means the caller is already gone -- it timed out, or this
    # process restarted while the publish was in flight. Dropping it is correct;
    # GenServer.reply/2 with a nil `from` would raise.
    case Map.pop(refs, ref) do
      {nil, refs} ->
        {:noreply, %State{state | refs: refs}}

      {from, refs} ->
        GenServer.reply(from, result)
        {:noreply, %State{state | refs: refs}}
    end
  end
end
