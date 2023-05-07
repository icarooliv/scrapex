defmodule ScrapexTest do
  use ExUnit.Case
  doctest Scrapex

  test "receives a valid url" do
    assert {:ok, _} = Scrapex.run("https://www.example.com")
  end

  test "returns error for an invalid url" do
    assert {:error, _} = Scrapex.run("www.example.com")
  end
end
