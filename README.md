# BinanceFutures

Binance Futures API Elixir implementation.

## Installation

1. The package can be installed by adding `binance_futures` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:binance_futures, "~> 0.1.0"}
  ]
end
```

2. Add `:binance_futures` to your applications list if your Elixir version is 1.3 or lower:

```elixir
def application do
  [applications: [:binance_futures]]
end
```

3. Add your Binance API credentials to your `config.exs` file, like so (you can create a new API
key [here](https://www.binance.com/en/support/faq/360002502072)):

```elixir
config :binance,
  api_key: "xxx",
  secret_key: "xxx"
```

## Usage

TBD.

Documentation can be found at [https://hexdocs.pm/binance_futures](https://hexdocs.pm/binance_futures).

