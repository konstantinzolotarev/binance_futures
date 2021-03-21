defmodule BinanceFutures do
  @moduledoc """
  Documentation for `BinanceFutures`.
  """

  @typedoc """
  Possible chart intervals for Kline/Candlestick requests.

   - m -> minutes
   - h -> hours
   - d -> days
   - w -> weeks
   - M -> months

  Available intervals: 
    
   - "1m"
   - "3m"
   - "5m"
   - "15m"
   - "30m"
   - "1h"
   - "2h"
   - "4h"
   - "6h"
   - "8h"
   - "12h"
   - "1d"
   - "3d"
   - "1w"
   - "1M"

  """
  @type interval :: binary

  @typedoc """
  Available contract types.

  List of available contract types:

   - PERPETUAL
   - CURRENT_MONTH
   - NEXT_MONTH
   - CURRENT_MONTH_DELIVERING - Invalid type, only used for DELIVERING status
   - NEXT_MONTH_DELIVERING - Invalid type, only used for DELIVERING status
  """
  @type contract_type :: String.t()
end
