defmodule Scrapex.Http.Client do
  @moduledoc """
  Implementation of `Scrapex.Http.Client` behaviour to work with HTTPoison and Mox.
  """

  @typep url :: binary()
  @typep headers :: [{atom, binary}] | [{binary, binary}] | %{binary => binary}
  @typep options :: Keyword.t()

  @callback get(url, headers, options) :: {:ok, map()} | {:error, binary() | map()}

  @doc """
  Get request.
  """

  def get(url, headers \\ [], options \\ []), do: impl().get(url, headers, options)

  defp impl(), do: Application.get_env(:scrapex, :http_client, Scrapex.Http.HTTPoison)
end
