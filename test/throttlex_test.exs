defmodule ThrottlexTest do
  use ExUnit.Case, async: true
  
  setup context do
    GenServer.start_link(Throttlex, [[name: :throttlex]])
    :ok
  end

  test "check rate" do
    rate_per_second = 10
    max_accumulated = 4
    cost = 1
    assert RateLimiter.check(1, rate_per_second, max_accumulated, cost) == :ok
    assert RateLimiter.check(1, rate_per_second, max_accumulated, cost) == :ok
    assert RateLimiter.check(1, rate_per_second, max_accumulated, cost) == :ok
    assert RateLimiter.check(1, rate_per_second, max_accumulated, cost) == :ok
    assert RateLimiter.check(1, rate_per_second, max_accumulated, cost) == :error

    :timer.sleep(100) # by this time, has recovered 1 token
    assert RateLimiter.check(1, rate_per_second, max_accumulated, cost) == :ok
    assert RateLimiter.check(1, rate_per_second, max_accumulated, cost) == :error
  end

end
