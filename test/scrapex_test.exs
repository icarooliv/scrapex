defmodule ScrapexTest do
  use ExUnit.Case
  doctest Scrapex

  test "receives a valid url" do
    assert {:ok, _} = Scrapex.scrape("https://www.google.com")
  end

  test "returns error for an invalid url" do
    assert {:error, _} = Scrapex.scrape("https://www.google.com")
  end
end
