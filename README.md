# Scrapex

UpLearn scraper challenge.

## Installation

### Requirements

- Elixir 1.14.2
- Erlang/OTP 25

### Instalation

- Clone:
  `git clone https://github.com/icarooliv/scrapex.git`
- Install dependencies

`cd scrapex`
`mix deps.get`

- Open the project with IEx:
  `iex -S mix`

## Usage

You can call the Scrapex.run/2 method. You can pass a valid URL and also a list of tuples in the following order: `{key_name, html_tag, html_attr}`.

### Examples

Successful:

```bash
iex> Scrapex.run("http://www.columbia.edu/~fdc/sample.html", [{"assets", "img", "src"}, {"links", "a", "href"}])
{:ok,
%{
  "assets" => ["http://www.columbia.edu/~fdc/picture-of-something.jpg"],
  "links" => ["http://www.columbia.edu/~fdc/",
    "https://kermitproject.org/newdeal/",
    "http://www.columbia.edu/cu/computinghistory",
    "http://www.columbia.edu/~fdc/family/dcmall.html",
    "http://www.columbia.edu/~fdc/family/hallshill.html",
    ...
    ]
}}
```

Invalid string:

```bash
iex(3)> Scrapex.run("abc", [{"assets", "img", "src"}, {"links", "a", "href"}])
{:error, :invalid_format}
```

```bash
iex(7)> Scrapex.run("https://elixirforum.com/t/page-missing", [{"assets", "img", "src"}, {"links", "a", "href"}])
{:error, 404}
```

Page not found:

```bash
iex> Scrapex.run("https://elixirforum.com/t/page-do-not-exist", [{"assets", "img", "src"}, {"links", "a", "href"}])
{:error, 404}
```

## Rationale and improvements

Here I discuss some thoughts and decisions that I had during this challenge.

### What was my design strategy?

I wanted to create the simplest that I could without missing the opportunities to show my skills even that it took more that the suggested time.

I also used TDD to guide me through the code design and its capabilities.

I used the Arrange Act Assert strategy to write my tests.

### Why wasting time creating a HTTPClient behaviour?

As José Valim explained [here](https://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/): "Mocks/stubs do not eliminate the need to define an explicit interface between your components." If I were to go with a non-contract approach, I would couple my Scrapex module with HTTPoison. However, I do not want to test HTTPoison; I want to test the contract between Scrapex and an HTTP client. Assuming that the project will evolve, it will be easier to keep the contract and change the implementation. Also, it'll not break tests that depend on this implementation.

In the test environment, I can define the [HTTP.ClientMock](https://github.com/icarooliv/scrapex/blob/main/test/test_helper.exs#L3-L4) as my client using Mox. This will rely on the [Scrapex.HTTP.Client](https://github.com/icarooliv/scrapex/blob/main/lib/scrapex/http/client.ex) behaviour. In other environments, I could use either a new module defined at the environment (such as a [Tesla implementation](https://github.com/teamon/tesla)) or a [default one](https://github.com/icarooliv/scrapex/blob/main/lib/scrapex/http/client.ex#L16-L19), such as HTTPoison in this case.

### Why I only wrote integration tests?

Because my time window to this task is small and the other modules are smaller enough to rely on integration tests. Obviously it would be a good idea to unit test the HTTP behaviour. As the `Scrapex` module have only one public function, the private ones are tested indirectly.

### Why Scrapex.run/1 fn doesn't have doctests?

Because it's a function with side effects. [See here](https://elixirforum.com/t/doctests-and-http-calls/1508/2).

## Assumptions

1. The url should accepts the formats `www.example.com`, `https://example.com` and other variations. If the url doesn't come with the schema prefix as `http` or `https`, it must be prepended to `https://`.
2. The scrape function must merge partial URL strings with the base URL.
3. The scrape function will not handle cases where a link points to a image and it's added to the `links` instead of `assets`.
4. This project is "platform agnostic" meaning it should be made in a way that it can be ported to a lib that can be installed, used as a umbrella app, imported as a git submodule, copy-pasted inside a Phoenix project etc.

## Next steps

1. Define a better structure for the HTTP responses. Now is just a map and if someone mistakenly changes the structure it'll break the code without warnings.
2. Do unit tests in the HTTP client behaviour.
3. Cache the results using Cachex or Nebulex. The k/v store can look like: `{url, scraping_result}`. The `Scrapex.run/2` function will accept an `opts` array where the user can define the TTL and if it should refresh the data, like so: `[refresh: true, ttl: 1000]`.

## Links/Libs that I used as inspiration

- [mix test.watch](https://github.com/lpil/mix-test.watch)
- [Dashbit's Bytepack project for URL validations](https://github.com/dashbitco/bytepack_archive/blob/main/apps/bytepack/lib/bytepack/extensions/ecto/validations.ex)
- [Using Mox with behaviours](https://blog.appsignal.com/2023/04/11/an-introduction-to-mocking-tools-for-elixir.html)
- [Scraping data with Floki](https://fullstackphoenix.com/tutorials/scraping-data-with-elixir-and-floki)
- [This discussion over http clients](https://elixirforum.com/t/mint-vs-finch-vs-gun-vs-tesla-vs-httpoison-etc/38588). I usually choose Tesla but wanted to try HTTPoison.
