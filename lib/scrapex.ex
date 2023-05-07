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
    case valid_url?(url) do
      true ->
        {:ok, url}

      _ ->
        {:error, :invalid_format}
    end
  end

  defp valid_url?(url) when is_binary(url) do
    URI.parse(url).scheme in ~w(http https)
  end
end
