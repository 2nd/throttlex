defmodule ThrottlexTest do
  use ExUnit.Case, async: true
  
  setup_all do
    GenServer.start_link(Throttlex, [])
    :ok
  end

  test "check rate" do
    assert Throttlex.check(:normal, 1) == :ok
    assert Throttlex.check(:normal, 1) == :ok
    assert Throttlex.check(:normal, 1) == :ok
    assert Throttlex.check(:normal, 1) == :ok
    assert Throttlex.check(:normal, 1) == :error

    :timer.sleep(100) # by this time, has recovered 1 token
    assert Throttlex.check(:normal, 1) == :ok
    assert Throttlex.check(:normal, 1) == :error
  end

  test "check rate on different tables" do
    assert Throttlex.check(:route_one, 1) == :ok
    assert Throttlex.check(:route_one, 1) == :ok
    assert Throttlex.check(:route_one, 1) == :error

    assert Throttlex.check(:route_two, 1) == :ok
    assert Throttlex.check(:route_two, 1) == :ok
    assert Throttlex.check(:route_two, 1) == :error
  end

  test "clear tables" do
    assert Throttlex.check(:clear, 1) == :ok
    assert Throttlex.check(:clear, 1) == :ok
    assert Throttlex.check(:clear, 1) == :error

    Throttlex.clear(:clear)
    assert Throttlex.check(:clear, 1) == :ok
  end

end
