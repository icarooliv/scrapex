defmodule ScrapexTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @html File.read!("test/support/fixtures/index.html")

  @tag_attrs [
    {"links", "a", "href"},
    {"assets", "img", "src"}
  ]

  test "receives a valid https url" do
    mock_get(@html)

    expected =
      {:ok,
       %{
         "assets" => [
           "https://www.example.com/image1.jpg",
           "https://www.example.com/images/image2.jpg",
           "https://www.example.com/images/image3.jpg"
         ],
         "links" => [
           "https://www.example.com",
           "https://www.example.com/about",
           "https://www.example.com/contact",
           "mailto:contact@example.com"
         ]
       }}

    assert ^expected = Scrapex.run("https://www.example.com", @tag_attrs)
  end

  test "receives a valid http url" do
    mock_get(@html)

    expected =
      {:ok,
       %{
         "assets" => [
           "https://www.example.com/image1.jpg",
           "http://www.example.com/images/image2.jpg",
           "http://www.example.com/images/image3.jpg"
         ],
         "links" => [
           "https://www.example.com",
           "http://www.example.com/about",
           "http://www.example.com/contact",
           "mailto:contact@example.com"
         ]
       }}

    assert ^expected = Scrapex.run("http://www.example.com", @tag_attrs)
  end

  test "accepts a url without scheme" do
    mock_get(@html)

    expected =
      {:ok,
       %{
         "assets" => [
           "https://www.example.com/image1.jpg",
           "https://www.example.com/images/image2.jpg",
           "https://www.example.com/images/image3.jpg"
         ],
         "links" => [
           "https://www.example.com",
           "https://www.example.com/about",
           "https://www.example.com/contact",
           "mailto:contact@example.com"
         ]
       }}

    assert ^expected = Scrapex.run("www.example.com", @tag_attrs)
  end

  test "returns error for invalid urls" do
    assert {:error, :invalid_format} = Scrapex.run("ws://javascript.info", @tag_attrs)

    assert {:error, :invalid_format} =
             Scrapex.run("foo://example.com:8042/over/there?name=ferret#nose", @tag_attrs)

    assert {:error, :invalid_format} = Scrapex.run("", @tag_attrs)

    assert {:error, :invalid_format} = Scrapex.run("invalid_url", @tag_attrs)
    assert {:error, :invalid_format} = Scrapex.run("https://invalid_url", @tag_attrs)

    assert {:error, :invalid_format} = Scrapex.run(nil, @tag_attrs)
  end

  test "returns error for failed requests" do
    mock_get_failure()

    assert {:error, 404} = Scrapex.run("https://page-does-not-exist.com", @tag_attrs)
  end

  def mock_get(response) do
    Scrapex.Http.ClientMock
    |> expect(:get, fn _, _, _ -> {:ok, %{body: response, status_code: 200}} end)
  end

  def mock_get_failure() do
    Scrapex.Http.ClientMock
    |> expect(:get, fn _, _, _ -> {:error, %{status_code: 404}} end)
  end
end
