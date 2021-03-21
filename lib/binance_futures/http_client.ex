defmodule BinanceFutures.HTTPClient do
  @moduledoc """
  Binance Futures HTTP Client.
  """

  alias BinanceFutures.RateLimiter
  alias BinanceFutures.AuthorizationError

  @type error :: {:error, HTTPoison.Error.t()} | {:error, Jason.DecodeError.t()}

  @api_key Application.get_env(:binance_futures, :api_key, "")
  @secret_key Application.get_env(:binance_futures, :secret_key, "")
  @endpoint Application.get_env(:binance_futures, :usdm_end_point)

  @doc """
  Makes direct get request to Binance Futures API.
  """
  @spec get(binary, nil | map | String.t(), HTTPoison.Base.headers()) :: {:ok, term} | error()
  def get(url, params \\ nil, headers \\ [])

  def get(url, params, headers) when is_map(params) do
    clear_params =
      params
      |> remove_nils()
      |> URI.encode_query()

    get(url, clear_params, headers)
  end

  def get(url, params, headers) when params in [nil, ""] do
    "#{@endpoint}#{url}"
    |> HTTPoison.get(headers)
    |> parse_response
  end

  def get(url, params, headers) when is_binary(params) do
    "#{@endpoint}#{url}?#{params}"
    |> HTTPoison.get(headers)
    |> parse_response
  end

  @doc """
  Makes authed get request to Binance Futures API.
  """
  @spec auth_get(binary, map | String.t(), HTTPoison.Base.headers(), boolean) ::
          {:ok, term} | error()
  def auth_get(url, params \\ nil, headers \\ [], require_signature? \\ false)

  def auth_get(url, params, headers, false),
    do: get(url, params, headers ++ [{"X-MBX-APIKEY", @api_key}])

  def auth_get(url, params, headers, true) do
    raise "Not implemented yet"
    get(url, params, headers ++ [{"X-MBX-APIKEY", @api_key}])
  end

  defp sign_query(%{} = params) do
  end

  defp remove_nils(%{} = data) do
    data
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end

  defp generate_signature!("", _),
    do: raise(AuthorizationError, message: "invalid secret key")

  defp generate_signature!(secret_key, params) when is_map(params) do
    generate_signature!(secret_key, URI.encode_query(params))
  end

  defp generate_signature!(secret_key, arguments) do
    :crypto.hmac(
      :sha256,
      secret_key,
      arguments
    )
    |> Base.encode16()
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, headers: headers}}) do
    RateLimiter.set(headers)

    body
    |> Jason.decode()
    |> process_parsed_response()
  end

  defp parse_response({:error, err}) do
    {:error, err}
  end

  defp process_parsed_response({:ok, %{"code" => _c, "msg" => _m} = err}),
    do: {:error, err}

  defp process_parsed_response({:ok, data}),
    do: {:ok, data}

  defp process_parsed_response({:error, err}) do
    {:error, err}
  end
end
