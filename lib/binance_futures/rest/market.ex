defmodule BinanceFutures.Rest.MarketData do
  @moduledoc """
  List of Market Data REST API's.
  """

  alias BinanceFutures.HTTPClient

  @doc """
  Tests API Connectivity.

  ## Example

      iex(1)> BinanceFutures.Rest.MarketData.ping()
      {:ok, %{}}

  """
  @spec ping() :: {:ok, map} | HTTPClient.error()
  def ping(),
    do: HTTPClient.get("/fapi/v1/ping")

  @doc """
  Gets Binance Futures API Server time.

  ## Example

      iex(1)> BinanceFutures.Rest.MarketData.server_time()
      {:ok, 1616276229598}

  """
  @spec server_time() :: {:ok, pos_integer} | HTTPClient.error()
  def server_time() do
    case HTTPClient.get("/fapi/v1/time") do
      {:ok, %{"serverTime" => time}} -> {:ok, time}
      err -> err
    end
  end

  @doc """
  Gets current exchange trading rules and symbol information.
  """
  @spec exchange_info() :: {:ok, map} | HTTPClient.error()
  def exchange_info(),
    do: HTTPClient.get("/fapi/v1/exchangeInfo")

  @doc """
  Gets Order Book.

  ## Example

      iex(1)> BinanceFutures.Rest.MarketData.depth("BTCUSDT")
      {:ok,
      %{
        "E" => 1616333020858,
        "T" => 1616333020851,
        "asks" => [
          ["56865.63", "3.972"],
          ["56865.64", "0.023"],
          ["56882.96", ...],
          [...],
          ...
        ],
        "bids" => [
          ["56865.62", "0.501"],
          ["56865.00", "0.003"],
          ["56862.63", "0.088"],
          ["56851.92", ...],
          [...],
          ...
        ],
        "lastUpdateId" => 272144015637
      }}
  """
  @spec depth(binary, pos_integer) :: {:ok, map} | HTTPClient.error()
  def depth(symbol, limit \\ 500),
    do: HTTPClient.get("/fapi/v1/depth?symbol=#{symbol}&limit=#{limit}")

  @doc """
  Gets recent trades.

  ## Example

      iex(1)> BinanceFutures.Rest.MarketData.recent_trades("BTCUSDT", 2)
      {:ok,
      [
        %{
          "id" => 625947549,
          "isBuyerMaker" => true,
          "price" => "57080.03",
          "qty" => "0.100",
          "quoteQty" => "5708.00",
          "time" => 1616333975439
        },
        %{
          "id" => 625947550,
          "isBuyerMaker" => true,
          "price" => "57080.03",
          "qty" => "0.011",
          "quoteQty" => "627.88",
          "time" => 1616333975579
        }
      ]}

  """
  @spec recent_trades(binary, pos_integer) :: {:ok, [map]} | HTTPClient.error()
  def recent_trades(symbol, limit \\ 500),
    do: HTTPClient.get("/fapi/v1/trades?symbol=#{symbol}&limit=#{limit}")

  @doc """
  Gets older market historical trades.

  ## Example

      iex(1)> BinanceFutures.Rest.MarketData.historical_trades("BTCUSDT", nil, 2)
      {:ok,
      [
        %{
          "id" => 626078533,
          "isBuyerMaker" => false,
          "price" => "57267.94",
          "qty" => "0.001",
          "quoteQty" => "57.26",
          "time" => 1616338040822
        },
        %{
          "id" => 626078534,
          "isBuyerMaker" => true,
          "price" => "57263.20",
          "qty" => "0.010",
          "quoteQty" => "572.63",
          "time" => 1616338040920
        }
      ]}

  """
  @spec historical_trades(binary, nil | pos_integer, pos_integer) ::
          {:ok, [map]} | HTTPClient.error()
  def historical_trades(symbol, from_id \\ nil, limit \\ 500) do
    params = %{
      "symbol" => symbol,
      "fromId" => from_id,
      "limit" => limit
    }

    HTTPClient.auth_get("/fapi/v1/historicalTrades", params)
  end

  @doc """
  Gets compressed, aggregate trades.
  Trades that fill at the time, from the same order, with the same price will have the quantity aggregated.

  ## Example

      iex(1)> BinanceFutures.Rest.MarketData.aggregate_trades("BTCUSDT", nil, nil, nil, 2)
      {:ok,
      [
        %{
          "T" => 1616338617973,
          "a" => 391916312,
          "f" => 626090468,
          "l" => 626090468,
          "m" => false,
          "p" => "57215.00",
          "q" => "0.002"
        },
        %{
          "T" => 1616338618243,
          "a" => 391916313,
          "f" => 626090469,
          "l" => 626090469,
          "m" => false,
          "p" => "57215.00",
          "q" => "0.030"
        }
      ]}

  """
  @spec aggregate_trades(
          binary,
          nil | pos_integer,
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [map]} | HTTPClient.error()
  def aggregate_trades(symbol, from_id \\ nil, start_time \\ nil, end_time \\ nil, limit \\ 500) do
    params = %{
      "symbol" => symbol,
      "fromId" => from_id,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/fapi/v1/aggTrades", params)
  end

  @doc """
  Gets Kline/candlestick bars for a symbol.
  Klines are uniquely identified by their open time.

  ## Example

      iex(1)> BinanceFutures.Rest.MarketData.klines("BTCUSDT", "5m", nil, nil, 2)
      {:ok,
      [
        [1616338800000, "57212.69", "57315.00", "57196.19", "57300.00", "496.263",
          1616339099999, "28425514.78940", 7160, "273.108", "15642623.69718", "0"],
        [1616339100000, "57300.00", "57300.00", "57200.61", "57206.47", "174.865",
          1616339399999, "10009130.07051", 2602, "60.409", "3457649.49072", "0"]
      ]}

  """
  @spec klines(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) ::
          {:ok, [list]} | HTTPClient.error()
  def klines(symbol, interval, start_time \\ nil, end_time \\ nil, limit \\ 500) do
    params = %{
      "symbol" => symbol,
      "interval" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/fapi/v1/klines", params)
  end

  @doc """
  Gets continuous Kline/candlestick bars for a specific contract type.
  Klines are uniquely identified by their open time.

  Contract types available:

   - PERPETUAL
   - CURRENT_MONTH
   - NEXT_MONTH

  ## Example

    iex(1)> BinanceFutures.Rest.MarketData.continuous_klines("BTCUSDT", "PERPETUAL", "5m", nil, nil, 2)
    {:ok,
    [
      [1616340000000, "57480.91", "57490.00", "57372.26", "57405.05", "571.101",
        1616340299999, "32796220.87635", 9024, "241.532", "13870331.23961", "0"],
      [1616340300000, "57405.05", "57430.00", "57350.00", "57385.99", "458.456",
        1616340599999, "26307719.07498", 6574, "198.989", "11419479.03403", "0"]
    ]}

  """
  @spec continuous_klines(
          binary,
          BinanceFutures.contract_type(),
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [list]} | HTTPClient.error()
  def continuous_klines(
        pair,
        contract_type,
        interval,
        start_time \\ nil,
        end_time \\ nil,
        limit \\ 500
      ) do
    params = %{
      "pair" => pair,
      "contractType" => contract_type,
      "interval" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/fapi/v1/continuousKlines", params)
  end

  @doc """
  Gets Kline/candlestick bars for the index price of a pair.
  Klines are uniquely identified by their open time.

  ## Example

    iex(1)> BinanceFutures.Rest.MarketData.index_price_klines("BTCUSDT", "5m", nil, nil, 2)
    {:ok,
    [
      [1616340600000, "57366.98431599", "57429.73139441", "57284.92735200",
        "57284.92735200", "0", 1616340899999, "0", 300, "0", "0", "0"],
      [1616340900000, "57283.26395200", "57294.43035200", "57224.03776400",
        "57265.85639717", "0", 1616341199999, "0", 89, "0", "0", "0"]
    ]}

  """
  @spec index_price_klines(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [list]} | HTTPClient.error()
  def index_price_klines(pair, interval, start_time \\ nil, end_time \\ nil, limit \\ 500) do
    params = %{
      "pair" => pair,
      "interval" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/fapi/v1/indexPriceKlines", params)
  end

  @doc """
  Gets Kline/candlestick bars for the mark price of a symbol.
  Klines are uniquely identified by their open time.

  ## Example

    iex(1)> BinanceFutures.Rest.MarketData.mark_price_klines("BTCUSDT", "5m", nil, nil, 2)
    {:ok,
    [
      [1616340900000, "57302", "57319.11709042", "57185.40000000",
        "57247.46000000", "0", 1616341199999, "0", 300, "0", "0", "0"],
      [1616341200000, "57240", "57311.07657677", "57240", "57307.87695491", "0",
        1616341499999, "0", 53, "0", "0", "0"]
    ]}

  """
  @spec mark_price_klines(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [list]} | HTTPClient.error()
  def mark_price_klines(symbol, interval, start_time \\ nil, end_time \\ nil, limit \\ 500) do
    params = %{
      "symbol" => symbol,
      "interval" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/fapi/v1/markPriceKlines", params)
  end

  @doc """
  Gets Mark Price and Funding Rate
  If no `symbol` provided, prices for all symbols will be returned.

  ## Example

    iex(1)> BinanceFutures.Rest.MarketData.mark_price("BTCUSDT")
    {:ok,
    %{
      "estimatedSettlePrice" => "57311.26556567",
      "indexPrice" => "57299.56815703",
      "interestRate" => "0.00010000",
      "lastFundingRate" => "0.00010000",
      "markPrice" => "57325.76000000",
      "nextFundingTime" => 1616342400000,
      "symbol" => "BTCUSDT",
      "time" => 1616341403005
    }}


    iex(2)> BinanceFutures.Rest.MarketData.mark_price()
    {:ok,
    [
      %{
        "estimatedSettlePrice" => "18.99792722",
        "indexPrice" => "18.98676895",
        "interestRate" => "0.00010000",
        "lastFundingRate" => "0.00036359",
        "markPrice" => "18.99830000",
        "nextFundingTime" => 1616342400000,
        "symbol" => "SUSHIUSDT",
        "time" => 1616341422000
      },
      %{
          "estimatedSettlePrice" => "2.71120145",
          "indexPrice" => "2.69011741",
          "interestRate" => "0.00010000",
          ...
        },
        %{
          "estimatedSettlePrice" => "196.26837596",
          "indexPrice" => "196.02526316",
          ...
        },
        %{"estimatedSettlePrice" => "3.96997638", ...},
        %{...},
        ...
      ]}
  """
  @spec mark_price(nil | binary) :: {:ok, map} | {:ok, [map]} | HTTPClient.error()
  def mark_price(symbol \\ nil),
    do: HTTPClient.get("/fapi/v1/premiumIndex", %{"symbol" => symbol})
end
