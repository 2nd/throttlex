defmodule Throttlex do
  use GenServer

  @table :throttlex_rate_limiter

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_args) do
    :ets.new(@table, [:public, :named_table, :set, write_concurrency: true])
    {:ok, nil}
  end

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
