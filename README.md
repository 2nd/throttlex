# Throttlex

Throttlex is a rate limiter based on erlang ETS.

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

## Usage

The `Throttlex.check` function will return `:ok` if the user's request could be allowed, otherwise will return `:error`.

Check user's rate, same rate_per_second, max_accumulated, cost should be passed to check functions
in order to inspect user's rate. And user id must be integer for efficiency issue.

**Arguments**:
 - `id`: id.
 - `rate_per_second`: how many rates should be added to bucket per second.
 - `max_accumulated`: maximum rates allowed in the bucket.
 - `cost`: costs of each request.

**Examples**:

  For user id 1, one extra request will be added to bucket, maximum accumulated requests number
  is 4, and every request will cost 1 token. First request will be permitted.

  ```elixir
  iex> Throttlex.check(1, 1, 2, 1)
  :ok
  ```

  Second request is permitted also since we allowed 2 requests maximum.

  ```elixir
  iex> Throttlex.check(1, 1, 2, 1)
  :ok
  ```

  If the third request is made within 1 second (the recovery time), it will return :error.

  ```elixir
  iex> Throttlex.check(1, 1, 2, 1)
  :error
  ```

## Testing

```elixir
mix test
```
