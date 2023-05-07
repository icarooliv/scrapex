defmodule ScrapexTest do
  use ExUnit.Case
  doctest Scrapex

  test "receives a valid url" do
    assert {:ok, _} = Scrapex.run("https://www.example.com")
    assert {:ok, _} = Scrapex.run("http://www.example.com")
  end

  test "returns error for not http/https urls" do
    assert {:error, _} = Scrapex.run("ws://javascript.info")
    assert {:error, _} = Scrapex.run("foo://example.com:8042/over/there?name=ferret#nose")
  end

  test "returns error for malformed urls" do
    assert {:error, _} = Scrapex.run("www.example.com")
  end
end
