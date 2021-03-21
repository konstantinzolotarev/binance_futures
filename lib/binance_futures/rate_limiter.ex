defmodule BinanceFutures.RateLimiter do
  @moduledoc """
  Rate Limiter handles Binance Futures API limits.

  More info could be found here: 
  https://binance-docs.github.io/apidocs/futures/en/#limits

  Binance API has two type of limits.
   
   - `weight` limit - you have N available weight by IP address per time frame
   - `orders` limit - you have N available calls to `ORDERS` API's per API Key, per time frame.

  Time frames for now are: 
   
   - `1M` - 1 Minute. Applicable for `weight` and `orders` limits.
   - `10S` - 10 Seconds. Applicable for `orders` limits only.

  By default it will only collect already used rates from API requests.
  And wouldn't be able to provide any remaining rate limits information.

  ## Already used rate limits

  To get already used limits for your IP/API Key you could use:

   - `BinanceFutures.RateLimiter.get/0` - Shows all available limits information (including remaining if fetched).
   - `BinanceFutures.RateLimiter.get_weight/0` - Shows used `weight` limits by time frame.
   - `BinanceFutures.RateLimiter.get_orders/0` - Shows used `orders` limits by time frame.

  ## Remaining limits

  If you need to keep track of remaining rate limits, you have to call 
  `BinanceFutures.RateLimiter.fetch_limits/0` function.

  ## Example

      iex(1)> BinanceFutures.RateLimiter.fetch_limits
      :ok

  It will spend some on your `weight` limit by calling 
  `BinanceFutures.Rest.MarketData.exchange_info/0` function.
  But also will grab remainig rate limits for your account.

  After this call you will be able to keep track on remaining limits by using:

   - `BinanceFutures.RateLimiter.remaining/0` - Shows all remaining limits.
   - `BinanceFutures.RateLimiter.remaining_orders/0` - Shows remaining orders limits by time frames.
   - `BinanceFutures.RateLimiter.remaining_weight/0` - Shows remaining weight limits by time frames.



  """

  use GenServer

  alias BinanceFutures.Rest.MarketData

  @weight_header "X-MBX-USED-WEIGHT-"
  @order_header "X-MBX-ORDER-COUNT-"

  @typedoc """
  Limit type.
  Contain time frame as key, example: `1M`, `10S`
  And actual limit as value: `1`, `2400`

  ## Example

      %{"1M" => 2399}

      %{"10S" => 300, "1M" => 1200}

  """
  @type limit :: %{optional(binary) => non_neg_integer}

  @typedoc """
  Limits for `weight` and `orders` types that fetched from 
  `BinanceFutures.Rest.MarketData.exchange_info/0`

  ## Example

    %{orders: %{"10S" => 300, "1M" => 1200}, weight: %{"1M" => 2400}}

  """
  @type limits :: %{weight: limit(), orders: limit()}


  defmodule State do
    @typedoc """
    Rate limiter state. 

     - `limits` - Limits pulled from exchange info.
     - `weight` - Used `weight` limits.
     - `orders` - Used `orders` limits.
    """
    @type t :: %{
      limits: BinanceFutures.RateLimiter.limits(),
      weight: BinanceFutures.RateLimiter.limit(),
      orders: BinanceFutures.RateLimiter.limit(),
    }
    defstruct limits: %{weight: %{}, orders: %{}},
              weight: %{},
              orders: %{}
  end

  @doc false
  def start_link(_opts \\ []),
    do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Parses used limits from given headers.

  Don't use this function if you don't know what are you doing !
  This function is used in all REST API calls.
  """
  @spec set(HTTPoison.Base.headers()) :: :ok
  def set(headers),
    do: GenServer.cast(__MODULE__, {:set, headers})

  @doc """
  Get all available limits information.

  Note that if you didn't call `BinanceFutures.RateLimiter.fetch_limits/0`
  `limits` field will be empty.

  ## Example

      iex(1)> BinanceFutures.RateLimiter.get()
      %{limits: %{orders: %{}, weight: %{}}, orders: %{}, weight: %{"1M" => 1}}
      iex(2)> BinanceFutures.RateLimiter.fetch_limits()
      :ok
      iex(3)> BinanceFutures.RateLimiter.get()
      %{
        limits: %{orders: %{"10S" => 300, "1M" => 1200}, weight: %{"1M" => 2400}},
        orders: %{},
        weight: %{"1M" => 2}
      }

  """
  @spec get() :: State.t()
  def get(),
    do: GenServer.call(__MODULE__, :get)

  @doc """
  Gets already used `weight` limit.

  ## Example
      
      iex(1)> BinanceFutures.RateLimiter.get_weight()
      %{}
      iex(2)> BinanceFutures.Rest.MarketData.server_time()
      {:ok, 1616347174621}
      iex(3)> BinanceFutures.RateLimiter.get_weight()
      %{"1M" => 2}

  """
  @spec get_weight() :: limit()
  def get_weight(),
    do: GenServer.call(__MODULE__, :get_weight)
    
  @spec get_orders() :: limit()
  def get_orders(),
    do: GenServer.call(__MODULE__, :get_orders)

  @doc """
  Fetches Binance Futures API limits.
  Uses `BinanceFutures.Rest.MarketData.exchange_info/0` function for pulling information.

  Returns `{:error, term}` in case of some issues with API call.

  ## Example

      iex(1)> BinanceFutures.RateLimiter.fetch_limits()
      :ok

  """
  @spec fetch_limits() :: :ok | {:error, term}
  def fetch_limits(),
    do: GenServer.call(__MODULE__, :fetch_limits)

  @doc """
  Gets remaining limits information.
  By default it does not calculate any remaining limits.
  To make it happen you have to call `BinanceFutures.RateLimiter.fetch_limits/0`
  before calling `BinanceFutures.RateLimiter.remaining/0`

  ## Example

      iex(1)> BinanceFutures.RateLimiter.remaining()
      %{orders: %{}, weight: %{}}
      iex(2)> BinanceFutures.Rest.MarketData.server_time()
      {:ok, 1616347615118}
      iex(3)> BinanceFutures.RateLimiter.remaining()
      %{orders: %{}, weight: %{}}
      iex(4)> BinanceFutures.RateLimiter.fetch_limits()
      :ok
      iex(5)> BinanceFutures.RateLimiter.remaining()
      %{orders: %{"10S" => 300, "1M" => 1200}, weight: %{"1M" => 2399}}

  """
  @spec remaining() :: %{orders: limit(), weight: limit()}
  def remaining(),
    do: GenServer.call(__MODULE__, :remaining)

  @doc """
  Gets remaining `weight` limits.
  By default it does not calculate any remaining limits.
  To make it happen you have to call `BinanceFutures.RateLimiter.fetch_limits/0`
  before calling `BinanceFutures.RateLimiter.remaining_weight/0`
  
  ## Example

      iex(1)> BinanceFutures.RateLimiter.remaining_weight()
      %{}
      iex(2)> BinanceFutures.Rest.MarketData.server_time()
      {:ok, 1616347833596}
      iex(3)> BinanceFutures.RateLimiter.remaining_weight()
      %{}
      iex(4)> BinanceFutures.RateLimiter.fetch_limits()
      :ok
      iex(5)> BinanceFutures.RateLimiter.remaining_weight()
      %{"1M" => 2398}

  """
  @spec remaining_weight() :: limit()
  def remaining_weight(),
    do: GenServer.call(__MODULE__, :remaining_weight)

  @doc """
  Gets remaining `orders` limits.
  By default it does not calculate any remaining limits.
  To make it happen you have to call `BinanceFutures.RateLimiter.fetch_limits/0`
  before calling `BinanceFutures.RateLimiter.remaining_orders/0`
  """
  @spec remaining_orders() :: limit()
  def remaining_orders(),
    do: GenServer.call(__MODULE__, :remaining_orders)

  ## Callbacks

  @impl true
  def init(_) do
    {:ok, %State{}}
  end

  @impl true
  def handle_cast({:set, headers}, %State{} = state) do
    weight =
      headers
      |> Enum.filter(fn {name, _} -> String.starts_with?(name, @weight_header) end)
      |> Enum.map(fn {name, weight} ->
        {String.replace(name, @weight_header, ""), String.to_integer(weight)}
      end)
      |> Enum.into(%{})

    orders =
      headers
      |> Enum.filter(fn {name, _} -> String.starts_with?(name, @order_header) end)
      |> Enum.map(fn {name, weight} ->
        {String.replace(name, @order_header, ""), String.to_integer(weight)}
      end)
      |> Enum.into(%{})

    {:noreply, %State{state | weight: weight, orders: orders}}
  end

  @impl true
  def handle_call(:fetch_limits, _from, %State{limits: limits} = state) do
    case MarketData.exchange_info() do
      {:ok, data} ->
        updated_limits =
          data
          |> Map.get("rateLimits")
          |> Enum.reduce(limits, &pick_limits/2)

        {:reply, :ok, %State{state | limits: updated_limits}}

      {:error, err} ->
        {:reply, {:error, err}, state}
    end
  end

  @impl true
  def handle_call(:get, _from, %State{} = state),
    do: {:reply, Map.from_struct(state), state}

  @impl true
  def handle_call(:get_weight, _from, %State{weight: weight} = state),
    do: {:reply, weight, state}

  @impl true
  def handle_call(:get_orders, _from, %State{orders: orders} = state),
    do: {:reply, orders, state}

  @impl true
  def handle_call(
        :remaining,
        _from,
        %State{
          limits: %{orders: orders_limits, weight: weight_limits},
          weight: weight,
          orders: orders
        } = state
      ) do
    orders =
      orders_limits
      |> Enum.map(fn {name, limit} ->
        {name, limit - Map.get(orders, name, 0)}
      end)
      |> Enum.into(%{})

    weight =
      weight_limits
      |> Enum.map(fn {name, limit} ->
        {name, limit - Map.get(weight, name, 0)}
      end)
      |> Enum.into(%{})

    res = %{
      orders: orders,
      weight: weight
    }

    {:reply, res, state}
  end

  @impl true
  def handle_call(
        :remaining_weight,
        _from,
        %State{
          limits: %{weight: weight_limits},
          weight: weight
        } = state
      ) do
    res =
      weight_limits
      |> Enum.map(fn {name, limit} ->
        {name, limit - Map.get(weight, name, 0)}
      end)
      |> Enum.into(%{})

    {:reply, res, state}
  end

  @impl true
  def handle_call(
        :remaining_orders,
        _from,
        %State{
          limits: %{orders: orders_limits},
          orders: orders
        } = state
      ) do
    res =
      orders_limits
      |> Enum.map(fn {name, limit} ->
        {name, limit - Map.get(orders, name, 0)}
      end)
      |> Enum.into(%{})

    {:reply, res, state}
  end

  defp pick_limits(
         %{
           "rateLimitType" => "REQUEST_WEIGHT",
           "intervalNum" => interval_num,
           "interval" => "MINUTE",
           "limit" => limit
         },
         %{weight: weight} = limits
       ) do
    weight = Map.put(weight, "#{interval_num}M", limit)
    %{limits | weight: weight}
  end

  defp pick_limits(
         %{
           "rateLimitType" => "ORDERS",
           "intervalNum" => interval_num,
           "interval" => interval,
           "limit" => limit
         },
         %{orders: orders} = limits
       ) do
    orders = Map.put(orders, "#{interval_num}#{String.first(interval)}", limit)
    %{limits | orders: orders}
  end

  defp pick_limits(_, limits),
    do: limits
end
