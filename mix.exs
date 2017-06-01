defmodule Throttlex.Mixfile do
  use Mix.Project

  def project do
    [app: :throttlex,
     version: "0.0.2",
     elixir: "~> 1.4",
     name: "Throttlex",
     deps: deps(),
     package: package(),
     description: description(),
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

  def deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      maintainers: ["michelle@secondspectrum.com"],
      links: %{"GitHub" => "https://github.com/2nd/throttlex"}
    ]
  end
end
