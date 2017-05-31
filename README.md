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

###Arguments:
 - `id`: id.
 - `rate_per_second`: how many rates should be added to bucket per second.
 - `max_accumulated`: maximum rates allowed in the bucket.
 - `cost`: costs of each request.

## Testing

```elixir
mix test
```
