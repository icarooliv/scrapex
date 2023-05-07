defmodule Scrapex do
  @moduledoc """
  Documentation for `Scrapex`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Scrapex.run("https://www.example.com")
      {:ok, "https://www.example.com"}

      iex> Scrapex.run("http://www.example.com")
      {:ok, "http://www.example.com"}

      iex> Scrapex.run("ws://www.example.com")
      {:error, :invalid_format}

  """
  def run(url) do
    case normalize_url(url) do
      {:ok, url} ->
        {:ok, url}

      {:error, message} ->
        {:error, message}
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
