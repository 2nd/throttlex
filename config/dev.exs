use Mix.Config

config :throttlex, :buckets,
  default_throttlex: [rate_per_second: 100, max_accumulated: 200, cost: 1]
