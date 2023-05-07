defmodule Scrapex do
  @moduledoc """
  Documentation for `Scrapex`.
  """

  alias Scrapex.Http

  def run(url, tag_attrs) do
    with {:ok, url} <- normalize_url(url),
         {:ok, %{body: body}} <- Http.Client.get(url) do
      scrape(body, tag_attrs, url)
    else
      {:error, %{status_code: status_code}} -> {:error, status_code}
      {:error, message} -> {:error, message}
    end
  end

  defp scrape(body, tag_attrs, url) do
    tag_attr_results = extract_tag_attrs(body, tag_attrs, url)
    {:ok, tag_attr_results}
  end

  defp normalize_url(url) do
    cond do
      is_nil(url) ->
        {:error, :invalid_format}

      valid_url?(url) ->
        {:ok, url}

      valid_url?("https://" <> url) && without_scheme?(url) ->
        {:ok, "https://" <> url}

      true ->
        {:error, :invalid_format}
    end
  end

  defp extract_tag_attrs(body, tag_attrs, url) do
    Enum.reduce(tag_attrs, %{}, fn {key, tag, attr}, acc ->
      extracted_values = extract_values(body, {tag, attr})

      extracted_values =
        cond do
          attr in ["href", "src"] -> Enum.map(extracted_values, &prepend_url(&1, url))
          true -> extracted_values
        end

      Map.put(acc, key, extracted_values)
    end)
  end

  defp extract_values(body, {tag, attr}) do
    body
    |> Floki.parse_document!()
    |> Floki.find(tag)
    |> Floki.attribute(attr)
    |> Enum.filter(&String.valid?/1)
  end

  defp prepend_url(maybe_path, url) do
    case URI.parse(maybe_path) do
      %URI{scheme: nil, path: path, fragment: fragment} ->
        partial = path || fragment || url

        URI.merge(url, partial)
        |> URI.to_string()

      _ ->
        maybe_path
    end
  end

  defp without_scheme?(url) do
    is_nil(URI.parse(url).scheme)
  end

  defp valid_url?(url) when is_binary(url) do
    uri = URI.parse(url)

    uri.host && uri.host =~ "." && uri.scheme in ~w(http https)
  end
end
