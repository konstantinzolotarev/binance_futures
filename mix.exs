defmodule BinanceFutures.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/konstantinzolotarev/binance_futures"

  def project do
    [
      app: :binance_futures,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),

      # Docs
      name: "Binance Futures API",
      source_url: @source_url,
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BinanceFutures.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Elixir wrapper for the Binance public API
    """
  end

  defp package do
    [
      maintainers: ["Konstantin Zolotarev"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
