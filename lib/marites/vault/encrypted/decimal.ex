defmodule Marites.Vault.Encrypted.Decimal do
  @moduledoc """
  Like Cloak.Ecto.Decimal, but rounds to 6 decimal places before encrypting.

  positions.latitude/longitude were plain `numeric(8,6)`/`numeric(9,6)`
  before the encryption-at-rest migration — Postgres silently rounded every
  value to 6 decimal places (~11cm precision) on insert, and
  `read_after_writes: true` re-read that rounded value back into the
  struct. An encrypted binary column has no such rounding (it's opaque
  bytes to Postgres), so this replicates it explicitly at the application
  level to keep stored precision identical to before — not implemented via
  `use Cloak.Ecto.Decimal` because overriding its `before_encrypt/1` a
  second time inside this module would shadow, not compose with, the one
  it already defines.
  """
  use Cloak.Ecto.Type, vault: Marites.Vault

  def cast(closure) when is_function(closure, 0), do: cast(closure.())
  def cast(value), do: Ecto.Type.cast(:decimal, value)

  def before_encrypt(value) do
    case Ecto.Type.cast(:decimal, value) do
      {:ok, d} -> d |> Decimal.round(6) |> Decimal.to_string()
      _error -> :error
    end
  end

  def after_decrypt(value) do
    case Decimal.new(value) do
      %Decimal{} = d -> d
      _error -> :error
    end
  end
end
