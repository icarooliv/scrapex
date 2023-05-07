defmodule ScrapexTest do
  use ExUnit.Case, async: true
  import Mox

  # setup do
  #   %{
  #     successful_response: File.read("/test/support/fixtures/200.html")
  #   }
  # end
  setup :verify_on_exit!

  test "receives a valid url" do
    response = File.read("/test/support/fixtures/200.html")
    mock_get(response)

    assert {:ok, _} = Scrapex.run("https://www.example.com")
    assert {:ok, _} = Scrapex.run("http://www.example.com")
    assert {:ok, _} = Scrapex.run("example.com")
  end

  test "returns error for not http/https urls" do
    assert {:error, :invalid_format} = Scrapex.run("ws://javascript.info")

    assert {:error, :invalid_format} =
             Scrapex.run("foo://example.com:8042/over/there?name=ferret#nose")
  end

  def mock_get(response) do
    Scrapex.Http.ClientMock
    |> expect(:get, 3, fn _, _, _ -> {:ok, %{body: response, status_code: 200}} end)
  end
end
