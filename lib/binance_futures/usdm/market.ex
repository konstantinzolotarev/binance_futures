defmodule BinanceFutures.USDM.MarketData do
  @moduledoc """
  List of Market Data REST API's.
  """

  alias BinanceFutures.HTTPClient

  @doc """
  Tests API Connectivity.

  Weight: 1

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.ping()
      {:ok, %{}}

  """
  @spec ping() :: {:ok, map} | HTTPClient.error()
  def ping(),
    do: HTTPClient.get("/fapi/v1/ping")

  @doc """
  Gets Binance Futures API Server time.
  Test connectivity to the Rest API and get the current server time.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.server_time()
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
  Current exchange trading rules and symbol information

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.exchange_info
      {:ok,
        %{
          "exchangeFilters" => [],
          "futuresType" => "U_MARGINED",
          "rateLimits" => [
            %{
              "interval" => "MINUTE",
              "intervalNum" => 1,
              "limit" => 2400,
              "rateLimitType" => "REQUEST_WEIGHT"
            },
            %{
              "interval" => "MINUTE",
              "intervalNum" => 1,
              "limit" => 1200,
              "rateLimitType" => "ORDERS"
            },
            %{
              "interval" => "SECOND",
              "intervalNum" => 10,
              "limit" => 300,
              "rateLimitType" => "ORDERS"
            }
          ],
          "serverTime" => 1616348890107,
          ...
          "timezone" => "UTC"
      }}

  """
  @spec exchange_info() :: {:ok, map} | HTTPClient.error()
  def exchange_info(),
    do: HTTPClient.get("/fapi/v1/exchangeInfo")

  @doc """
  Gets Order Book.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.depth("BTCUSDT")
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

      iex(1)> BinanceFutures.USDM.MarketData.recent_trades("BTCUSDT", 2)
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

      iex(1)> BinanceFutures.USDM.MarketData.historical_trades("BTCUSDT", nil, 2)
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

      iex(1)> BinanceFutures.USDM.MarketData.aggregate_trades("BTCUSDT", nil, nil, nil, 2)
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

      iex(1)> BinanceFutures.USDM.MarketData.klines("BTCUSDT", "5m", nil, nil, 2)
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

      iex(1)> BinanceFutures.USDM.MarketData.continuous_klines("BTCUSDT", "PERPETUAL", "5m", nil, nil, 2)
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

      iex(1)> BinanceFutures.USDM.MarketData.index_price_klines("BTCUSDT", "5m", nil, nil, 2)
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

      iex(1)> BinanceFutures.USDM.MarketData.mark_price_klines("BTCUSDT", "5m", nil, nil, 2)
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

      iex(1)> BinanceFutures.USDM.MarketData.mark_price("BTCUSDT")
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
      iex(2)> BinanceFutures.USDM.MarketData.mark_price()
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

  @doc """
  Gets Funding Rate History.

  Additional API details:

   - If startTime and endTime are not sent, the most recent limit datas are returned.
   - If the number of data between startTime and endTime is larger than limit, return as startTime + limit.
   - In ascending order.

  If `symbol` will be omitted rates for all `symbols` will be returned.

  ## Example

      iex(3)> BinanceFutures.USDM.MarketData.funding_rate("BNBUSDT")
      {:ok,
      [
        %{
          "fundingRate" => "-0.00149526",
          "fundingTime" => 1601971200005,
          "symbol" => "BNBUSDT"
        },
        %{
          "fundingRate" => "-0.00081215",
          "fundingTime" => 1602000000000,
          "symbol" => "BNBUSDT"
        },
        %{"fundingRate" => "0.00000000", "fundingTime" => 1603267200004, ...},
        %{"fundingRate" => "0.00000000", ...},
        %{...},
        ...
      ]}

  """
  @spec funding_rate(nil | binary, nil | pos_integer, nil | pos_integer, pos_integer) ::
          {:ok, map} | {:ok, [map]} | HTTPClient.error()
  def funding_rate(symbol \\ nil, start_time \\ nil, end_time \\ nil, limit \\ 500) do
    params = %{
      "symbol" => symbol,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/fapi/v1/fundingRate", params)
  end

  @doc """
  Gets 24hr Ticker Price Change Statistics.

  24 hour rolling window price change statistics.
  Careful when accessing this with no symbol (has very big `weight`).

  If the symbol is not sent, tickers for all symbols will be returned in an array.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.ticker_24h("BTCUSDT")
      {:ok,
      %{
        "closeTime" => 1616437801503,
        "count" => 2829671,
        "firstId" => 626470086,
        "highPrice" => "58500.00",
        "lastId" => 629299761,
        "lastPrice" => "57028.37",
        "lastQty" => "0.025",
        "lowPrice" => "56243.00",
        "openPrice" => "57325.02",
        "openTime" => 1616351400000,
        "priceChange" => "-296.65",
        "priceChangePercent" => "-0.517",
        "quoteVolume" => "13059748167.78",
        "symbol" => "BTCUSDT",
        "volume" => "227696.666",
        "weightedAvgPrice" => "57355.90"
      }}

  """
  @spec ticker_24h(nil | binary) :: {:ok, map} | {:ok, [map]} | HTTPClient.error()
  def ticker_24h(symbol \\ nil),
    do: HTTPClient.get("/fapi/v1/ticker/24hr", %{"symbol" => symbol})

  @doc """
  Gets Symbol Price Ticker.
  Latest price for a symbol or symbols.

  If the symbol is not sent, prices for all symbols will be returned in an array.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.ticker_price("BTCUSDT")
      {:ok, %{"price" => "56832.56", "symbol" => "BTCUSDT", "time" => 1616437944238}}

  """
  @spec ticker_price(nil | binary) :: {:ok, map} | {:ok, [map]} | HTTPClient.error()
  def ticker_price(symbol \\ nil),
    do: HTTPClient.get("/fapi/v1/ticker/price", %{"symbol" => symbol})

  @doc """
  Gets Symbol Order Book Ticker.  
  Best price/qty on the order book for a symbol or symbols.

  If the symbol is not sent, bookTickers for all symbols will be returned in an array.

  ## Example

      iex(7)> BinanceFutures.USDM.MarketData.ticker_book("BTCUSDT")
      {:ok,
      %{
        "askPrice" => "56685.27",
        "askQty" => "0.077",
        "bidPrice" => "56683.18",
        "bidQty" => "1.392",
        "symbol" => "BTCUSDT",
        "time" => 1616438105137
      }}

  """
  @spec ticker_book(nil | binary) :: {:ok, map} | {:ok, [map]} | HTTPClient.error()
  def ticker_book(symbol \\ nil),
    do: HTTPClient.get("/fapi/v1/ticker/bookTicker", %{"symbol" => symbol})

  @doc """
  Gets all Liquidation Orders.

  If the symbol is not sent, liquidation orders for all symbols will be returned.
  The query time period must be within the recent 7 days.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.all_force_orders("BTCUSDT", nil, nil, 1)
      {:ok,
      [
        %{
          "averagePrice" => "56560.35",
          "executedQty" => "0.002",
          "origQty" => "0.002",
          "price" => "56316.25",
          "side" => "SELL",
          "status" => "FILLED",
          "symbol" => "BTCUSDT",
          "time" => 1616438506969,
          "timeInForce" => "IOC",
          "type" => "LIMIT"
        }
      ]}

  """
  @spec all_force_orders(nil | binary, nil | pos_integer, nil | pos_integer, pos_integer) ::
          {:ok, [map]} | HTTPClient.error()
  def all_force_orders(symbol \\ nil, start_time \\ nil, end_time \\ nil, limit \\ 100) do
    params = %{
      "symbol" => symbol,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/fapi/v1/allForceOrders", params)
  end

  @doc """
  Gets present open interest of a specific symbol.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.open_interest("BTCUSDT")
      {:ok,
      %{
        "openInterest" => "33877.933",
        "symbol" => "BTCUSDT",
        "time" => 1616438337232
      }}

  """
  @spec open_interest(binary) :: {:ok, map} | HTTPClient.error()
  def open_interest(symbol),
    do: HTTPClient.get("/fapi/v1/openInterest?symbol=#{symbol}")

  @doc """
  Gets Open Interest Statistics.

  If startTime and endTime are not sent, the most recent data is returned.
  Only the data of the latest 30 days is available.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.open_interest_hist("BTCUSDT", "5m", nil, nil, 1)
      {:ok,
      [
        %{
          "sumOpenInterest" => "34085.00000000",
          "sumOpenInterestValue" => "1927265695.27131325",
          "symbol" => "BTCUSDT",
          "timestamp" => 1616438700000
        }
      ]}

  """
  @spec open_interest_hist(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [map]} | HTTPClient.error()
  def open_interest_hist(symbol, interval \\ nil, start_time \\ nil, end_time \\ nil, limit \\ 30) do
    params = %{
      "symbol" => symbol,
      "period" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/futures/data/openInterestHist", params)
  end

  @doc """
  Gets Top Trader Long/Short Ratio (Accounts).

  If startTime and endTime are not sent, the most recent data is returned.
  Only the data of the latest 30 days is available.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.top_long_short_account_ratio("BTCUSDT", "5m", nil, nil, 1)
      {:ok,
      [
        %{
          "longAccount" => "0.7739",
          "longShortRatio" => "3.4228",
          "shortAccount" => "0.2261",
          "symbol" => "BTCUSDT",
          "timestamp" => 1616439000000
        }
      ]}

  """
  @spec top_long_short_account_ratio(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [map]} | HTTPClient.error()
  def top_long_short_account_ratio(
        symbol,
        interval,
        start_time \\ nil,
        end_time \\ nil,
        limit \\ 30
      ) do
    params = %{
      "symbol" => symbol,
      "period" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.auth_get("/futures/data/topLongShortAccountRatio", params)
  end

  @doc """
  Gets Top Trader Long/Short Ratio (Positions).

  If startTime and endTime are not sent, the most recent data is returned.
  Only the data of the latest 30 days is available.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.top_long_short_position_ratio("BTCUSDT", "5m", nil, nil, 1)
      {:ok,
        [
          %{
            "longAccount" => "0.5482",
            "longShortRatio" => "1.2131",
            "shortAccount" => "0.4518",
            "symbol" => "BTCUSDT",
            "timestamp" => 1616439300000
          }
        ]}

  """
  @spec top_long_short_position_ratio(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [map]} | HTTPClient.error()
  def top_long_short_position_ratio(
        symbol,
        interval,
        start_time \\ nil,
        end_time \\ nil,
        limit \\ 30
      ) do
    params = %{
      "symbol" => symbol,
      "period" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/futures/data/topLongShortPositionRatio", params)
  end

  @doc """
  Gets global Long/Short Ratio.

  If startTime and endTime are not sent, the most recent data is returned.
  Only the data of the latest 30 days is available.


  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.global_long_short_account_ratio("BTCUSDT", "5m", nil, nil, 1)
      {:ok,
      [
        %{
          "longAccount" => "0.7895",
          "longShortRatio" => "3.7506",
          "shortAccount" => "0.2105",
          "symbol" => "BTCUSDT",
          "timestamp" => 1616439600000
        }
      ]}

  """
  @spec global_long_short_account_ratio(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [map]} | HTTPClient.error()
  def global_long_short_account_ratio(
        symbol,
        interval,
        start_time \\ nil,
        end_time \\ nil,
        limit \\ 30
      ) do
    params = %{
      "symbol" => symbol,
      "period" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/futures/data/globalLongShortAccountRatio", params)
  end

  @doc """
  Gets Taker Long/Short Ratio.

  If startTime and endTime are not sent, the most recent data is returned.
  Only the data of the latest 30 days is available.


  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.taker_long_short_ratio("BTCUSDT", "5m", nil, nil, 1)
      {:ok,
      [
        %{
          "buySellRatio" => "1.1603",
          "buyVol" => "298.2800",
          "sellVol" => "257.0660",
          "timestamp" => 1616439300000
        }
      ]}

  """
  @spec taker_long_short_ratio(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [map]} | HTTPClient.error()
  def taker_long_short_ratio(
        symbol,
        interval,
        start_time \\ nil,
        end_time \\ nil,
        limit \\ 30
      ) do
    params = %{
      "symbol" => symbol,
      "period" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/futures/data/takerlongshortRatio", params)
  end

  @doc """
  Gets the BLVT NAV system is based on Binance Futures, so the endpoint is based on fapi.

  **Symbol** here is not as everywhere.
  Here `symbol` means TOKEN_NAME + `DOWN`|`UP`
  Example: `BTCDOWN` or `BTCUP`

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.lvt_klines("BTCDOWN", "5m", nil, nil, 1)
      {:ok,
      [
        [1616439900000, "0.05134788", "0.05217493", "0.05113578", "0.05186245",
          "2.56527976", 1616440199999, "0", 274, "703.56900864", "0", "0"]
      ]}

  """
  @spec lvt_klines(
          binary,
          BinanceFutures.interval(),
          nil | pos_integer,
          nil | pos_integer,
          pos_integer
        ) :: {:ok, [map]} | HTTPClient.error()
  def lvt_klines(
        symbol,
        interval,
        start_time \\ nil,
        end_time \\ nil,
        limit \\ 30
      ) do
    params = %{
      "symbol" => symbol,
      "interval" => interval,
      "startTime" => start_time,
      "endTime" => end_time,
      "limit" => limit
    }

    HTTPClient.get("/fapi/v1/lvtKlines", params)
  end

  @doc """
  Gets Composite Index Symbol Information.

  Only for composite index symbols.

  ## Example

      iex(1)> BinanceFutures.USDM.MarketData.index_info("DEFIUSDT")
      {:ok,
      %{
        "baseAssetList" => [
          %{
            "baseAsset" => "1INCH",
            "weightInPercentage" => "0.03031300",
            "weightInQuantity" => "16.58633812"
          },
          %{
            "baseAsset" => "AAVE",
            "weightInPercentage" => "0.05795000",
            "weightInQuantity" => "0.40345195"
          },
          ...
          %{
            "baseAsset" => "ZRX",
            "weightInPercentage" => "0.02559600",
            "weightInQuantity" => "42.58378099"
          }
        ],
        "symbol" => "DEFIUSDT",
        "time" => 1616440368000
      }}

  """
  @spec index_info(nil | binary) :: {:ok, [map]} | HTTPClient.error()
  def index_info(symbol \\ nil),
    do: HTTPClient.get("/fapi/v1/indexInfo", %{"symbol" => symbol})
end
