use Mix.Config

config :throttlex, :buckets,
  normal: [rate_per_second: 10, max_accumulated: 4, cost: 1],
  route_one: [rate_per_second: 1, max_accumulated: 2, cost: 1],
  route_two: [rate_per_second: 1, max_accumulated: 2, cost: 1],
  clear: [rate_per_second: 1, max_accumulated: 2, cost: 1]
