defmodule Scrapex.Http.HTTPoison do
  @behaviour Scrapex.Http.Client

  def get(url, headers \\ [], options \\ []) do
    case HTTPoison.get(url, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, %{body: body, status_code: 200}}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{body: body, status_code: status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
