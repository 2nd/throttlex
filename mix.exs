defmodule Throttlex.Mixfile do
  use Mix.Project

  def project do
    [app: :throttlex,
     version: "0.0.1",
     elixir: "~> 1.4",
     name: "Throttlex",
     description: description,
     package: package,
     source_url: "https://github.com/2nd/throttlex",
     homepage_url: "https://github.com/2nd/throttlex",
     docs: [extras: ["README.md"]]]
  end

  defp description do
    """
    Throttlex is a rate limiter based on leaky bucket algorithms.
    """
  end

  def application do
    [
      mod: {Throttlex.App, []},
      applications: [:logger]
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/2nd/throttlex"}
    ]
  end
end
