ExUnit.start()

Mox.defmock(Scrapex.Http.ClientMock, for: Scrapex.Http.Client)
Application.put_env(:scrapex, :http_client, Scrapex.Http.ClientMock)
