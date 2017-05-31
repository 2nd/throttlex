defmodule Throttlex do
  @moduledoc """
  Throttlex implements leaky bucket algorithm for rate limiting, it uses erlang ETS for storage.
  """

  use GenServer
  @table :throttlex_rate_limiter

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @doc false
  def init(_args) do
    :ets.new(@table, [:public, :named_table, :set, write_concurrency: true])
    {:ok, nil}
  end

  @doc """
  Check user's rate, same rate_per_second, max_accumulated, cost should be passed to check functions
  in order to inspect user's rate. And user id must be integer for efficiency issue.

  ##Arguments:
   - `id`: id.
   - `rate_per_second`: how many rates should be added to bucket per second.
   - `max_accumulated`: maximum rates allowed in the bucket.
   - `cost`: costs of each request.

  ##Examples:
    # For user id 1, one extra request will be added to bucket, maximum accumulated requests number
    is 4, and every request will cost 1 token. First request will be permitted.
    iex> Throttlex.check(1, 1, 2, 1)
    :ok
  
    # Second request is permitted also since we allowed 2 requests maximum.
    iex> Throttlex.check(1, 1, 2, 1)
    :ok

    # If the third request is made within 1 second (the recovery time), it will return :error.
    iex> Throttlex.check(1, 1, 2, 1)
    :error
  """

  @spec check(integer, integer, integer, integer) :: :ok | :error
  def check(id, rate_per_second, max_accumulated, cost) do
    now = :erlang.system_time(:milli_seconds)
    case :ets.lookup(@table, id) do
      [] ->
        :ets.insert(@table, {id, max_accumulated - cost, now})
        :ok
      [{id, tokens_left, last_time}] ->
        tokens = tokens_left + (now - last_time)/1000 * rate_per_second

        tokens = case tokens > max_accumulated do
          true -> max_accumulated
          false -> tokens
        end

        case tokens < cost do
          true -> :error
          false ->
            :ets.update_element(@table, id, [{2, tokens - cost} ,{3, now}])
            :ok
        end
    end
  end

end
