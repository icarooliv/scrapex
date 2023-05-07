defmodule Scrapex do
  @moduledoc """
  Documentation for `Scrapex`.
  """

  alias Scrapex.Http

  def run(url) do
    case normalize_url(url) do
      {:ok, url} ->
        scrape(url)

      {:error, message} ->
        {:error, message}
    end
  end

  defp scrape(url) do
    case Http.Client.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, _} ->
        {:error, :scrape_failed}
    end
  end

  defp normalize_url(url) do
    cond do
      valid_url?(url) ->
        {:ok, url}

      valid_url?("https://" <> url) && without_scheme?(url) ->
        {:ok, "https://" <> url}

      true ->
        {:error, :invalid_format}
    end
  end

  defp without_scheme?(url) do
    is_nil(URI.parse(url).scheme)
  end

  defp valid_url?(url) when is_binary(url) do
    URI.parse(url).scheme in ~w(http https)
  end
end
