defmodule Throttlex do
  @moduledoc """
  Throttlex implements leaky bucket algorithm for rate limiting, it uses erlang ETS for storage.
  """

  use GenServer
  
  @name :throttlex
  @default_opts [rate_per_second: 100, max_accumulated: 100, cost: 1]

  @doc false
  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: @name])
  end

  @doc false
  def init(_args), do: {:ok, nil}

  @doc false
  def handle_call({:create, tables}, _from, _state) do
    new_table(tables)
    {:reply, nil, nil}
  end

  @spec new_table(atom | [atom]) :: nil
  defp new_table([]), do: nil
  defp new_table([name | names]) when is_list(names) do
    :ets.new(name, [:public, :named_table, :set, write_concurrency: true, read_concurrency: true])
    new_table(names)
  end

  defp new_table(name), do: new_table([name])

  @doc """
  Sometimes different endpoints or different routes would want their own rate-limiter with specified 
  rates and cost, so this let you create multiple tables on startup, 

  ##Examples:
    iex> Throttlex.create_tables(:user_request)
    nil
  """
  @spec create_tables(atom | [atom]) :: nil
  def create_tables(names) do
    GenServer.call(@name, {:create, names})
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

  @spec check(atom, integer | binary | tuple | atom, integer, integer, integer) :: :ok | :error
  def check(table, id, rate_per_second, max_accumulated, cost) do
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
end
