defmodule Marites.UserApiSupervisorTest do
  use ExUnit.Case, async: false

  alias Marites.{UserApiSupervisor, ApiRegistry}

  test "running?/1 returns false for unknown user" do
    refute UserApiSupervisor.running?(99999)
  end

  test "via/1 returns a valid Registry via tuple" do
    assert {:via, Registry, {ApiRegistry, 42}} = ApiRegistry.via(42)
  end
end
