defmodule Throttlex do
  @moduledoc """
  Throttlex implements leaky bucket algorithm for rate limiting, it uses erlang ETS for storage.
  """
  use GenServer

  @buckets Application.get_env(:throttlex, :buckets) || []

  @type key :: integer | binary | tuple | atom

  @spec check(atom, key) :: :ok | :error
  def check(name, id), do: check(name, id, nil)

  @spec check(atom, key, integer | nil) :: :ok | :error
  Enum.map(@buckets, fn {name, config} ->
    [rate_per_second: rate, max_accumulated: max, cost: cost] = config
    def check(unquote(name), id, cost) do
      Throttlex.do_check(unquote(name), id, unquote(rate), unquote(max), cost || unquote(cost))
    end
  end)

  def check(name, _id, _cost) do
    raise "#{name} is not configured"
  end

  @doc false
  def start_link() do
    if Application.get_env(:throttlex, :verbose, false) == true do
      IO.inspect @buckets
    end
    new_table(Keyword.keys(@buckets))
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  @spec new_table([atom]) :: nil
  defp new_table([]), do: nil
  defp new_table([name | names]) do
    :ets.new(name, [:public, :named_table, :set, write_concurrency: true, read_concurrency: true])
    new_table(names)
  end

  @doc """
  Check user's rate, same `rate_per_second`, `max_accumulated` should be passed to check functions
  in order to inspect user's rate.

  ##Arguments:
   - `table`: an atom representing bucket name.
   - `id`: id.
   - `rate_per_second`: how many rates should be added to bucket per second.
   - `max_accumulated`: maximum rates allowed in the bucket.
   - `cost`: costs of each request.

  ##Examples:
    # For user id 1, one extra request will be added to bucket, maximum accumulated requests number
    is 4, and every request will cost 1 token. First request will be permitted.
    iex> Throttlex.check(:user_request, 1, 1, 2, 1)
    :ok

    # Second request is permitted also since we allowed 2 requests maximum.
    iex> Throttlex.check(:user_request, 1, 1, 2, 1)
    :ok

    # If the third request is made within 1 second (the recovery time), it will return :error.
    iex> Throttlex.check(:user_request, 1, 1, 2, 1)
    :error
  """

  @spec do_check(atom, key, integer, integer, integer) :: :ok | :error
  def do_check(table, id, rate_per_second, max_accumulated, cost) do
    now = :erlang.system_time(:milli_seconds)
    case :ets.lookup(table, id) do
      [] ->
        :ets.insert(table, {id, max_accumulated - cost, now})
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
            :ets.update_element(table, id, [{2, tokens - cost} ,{3, now}])
            :ok
        end
    end
  end

  @doc """
  Clear given ets table, this is often needed in tests
  """
  @spec clear(atom | [atom] ) :: :ok
  def clear([]), do: :ok
  def clear([table | tables]) do
    clear(table)
    clear(tables)
  end

  def clear(table) do
    :ets.delete_all_objects(table)
    :ok
  end

  def clear_all() do
    clear(Keyword.keys(@buckets))
  end

  def inspect(table, id) do
    case :ets.lookup(table, id) do
      [] -> nil
      [{_id, tokens_left, _last_time}] -> tokens_left
    end
  end
end
