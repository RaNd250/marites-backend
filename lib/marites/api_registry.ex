defmodule Marites.ApiRegistry do
  def child_spec(_opts) do
    Registry.child_spec(keys: :unique, name: __MODULE__)
  end

  def via(user_id), do: {:via, Registry, {__MODULE__, user_id}}
end
