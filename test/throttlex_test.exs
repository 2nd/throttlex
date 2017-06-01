defmodule ThrottlexTest do
  use ExUnit.Case, async: true
  
  setup_all do
    GenServer.start_link(Throttlex, [])
    Throttlex.create_tables([:normal, :route_one, :route_two])
    :ok
  end

  test "check rate" do
    rate_per_second = 10
    max_accumulated = 4
    cost = 1
    assert Throttlex.check(:normal, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:normal, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:normal, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:normal, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:normal, 1, rate_per_second, max_accumulated, cost) == :error

    :timer.sleep(100) # by this time, has recovered 1 token
    assert Throttlex.check(:normal, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:normal, 1, rate_per_second, max_accumulated, cost) == :error
  end

  test "check rate on different tables" do
    rate_per_second = 1
    max_accumulated = 2
    cost = 1
    assert Throttlex.check(:route_one, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:route_one, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:route_one, 1, rate_per_second, max_accumulated, cost) == :error

    assert Throttlex.check(:route_two, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:route_two, 1, rate_per_second, max_accumulated, cost) == :ok
    assert Throttlex.check(:route_two, 1, rate_per_second, max_accumulated, cost) == :error
  end

end
