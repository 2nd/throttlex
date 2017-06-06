# Throttlex

Throttlex is an efficient Elixir rate limiter based on erlang ETS.

## Instalation
1. Add Throttlex to your `mix.exs` dependencies:

    ```elixir
    def deps do
      [{:throttlex, "~> 0.0.1"}]
    end
    ```

2. List `:throttlex` in your application dependencies:

    ```elixir
    def application do
      [applications: [:throttlex]]
    end
    ```

3. Put configuration in your config file:

    ```elixir
    config :throttlex, :buckets,
      user_rate_web: [rate_per_second: 10, max_accumulated: 4, cost: 1],
      user_rate_ios: [rate_per_second: 10, max_accumulated: 4, cost: 1]
    ```

## Usage

**Check rate**:

The `Throttlex.check` function will return `:ok` if the user's request could be allowed, otherwise will return `:error`. For one bucket,
same `rate_per_second`, `max_accumulated` should be passed to `&check/5`.

 - `bucket`: an atom representing bucket name (also an ETS table).
 - `id`: id.
 - `cost`(optional): costs of each request.


```elixir
iex> Throttlex.check(:user_rate_web, 1)
:ok
iex> Throttlex.check(:user_rate_web, 1)
:ok
iex> Throttlex.check(:user_rate_web, 1)
:error
```

For user id 1, one extra request will be added to bucket, maximum accumulated requests number
is 4, and every request will cost 1 token. First request will be permitted.
Second request is permitted also since we allowed 2 requests maximum.
If the third request is made within 1 second (the recovery time), it will return :error.

```elixir
iex> Throttlex.clear(:user_rate_web)
:ok

iex> Throttlex.clear([:user_rate_web, user_rate_ios])
:ok
```

Clear given table/tables, will always return :ok.

## Testing

```elixir
mix test
```
