defmodule WorkOS.HttpClient do
  @moduledoc """
    A behaviour for HTTP clients that WorkOS can use.

    The default HTTP client is `WorkOS.HackneyClient`.

    To configure a different HTTP client, implement the `WorkOS.HTTPClient` behaviour and
     change the `:client` configuration:

         config :workos,
           client: MyHTTPClient

    ## Alternative Clients

      Let's look at an example of using an alternative HTTP client. In this example, we'll
      use [Finch](https://github.com/sneako/finch), a lightweight HTTP client for Elixir.

      First, we need to add Finch to our dependencies:

          # In mix.exs
          defp deps do
            [
              # ...
              {:finch, "~> 0.16"}
            ]
          end

      Then, we need to define a module that implements the `WorkOS.HTTPClient` behaviour:

          defmodule MyApp.WorkOSFinchHTTPClient do
            @behaviour WorkOS.HTTPClient

            @impl true
            def child_spec do
              Supervisor.child_spec({Finch, name: __MODULE__}, id: __MODULE__)
            end

            @impl true
            def post(url, headers, body) do
              request = Finch.build(:post, url, headers, body)

              case Finch.request(request, __MODULE__) do
                {:ok, %Finch.Response{status: status, headers: headers, body: body}} ->
                  {:ok, status, headers, body}

                {:error, error} ->
                  {:error, error}
              end
            end
          end

      Last, we need to configure WorkOS to use our new HTTP client:

          config :workos,
            client: MyApp.WorkOSFinchHTTPClient
  """

  @typedoc """
  The response status for an HTTP request.
  """
  @typedoc since: "1.0.0"
  @type status :: 100..599

  @typedoc """
  HTTP request or response headers.
  """
  @type headers :: [{String.t(), String.t()}]

  @typedoc """
  HTTP request or response body.
  """
  @typedoc since: "1.0.0"
  @type body :: binary()

  @doc """
  Should return a **child specification** to start the HTTP client.

  For example, this can start a pool of HTTP connections dedicated to WorkOS SDK.
  If not provided, WorkOS SDK won't do anything to start your HTTP client. See
  [the module documentation](#module-child-spec) for more info.
  """
  @callback child_spec() :: :supervisor.child_spec()

  @doc """
  Should make an HTTP `POST` request to `url` with the given `headers` and `body`.
  """
  @callback post(url :: String.t(), request_headers :: headers(), request_body :: body()) ::
              {:ok, status(), response_headers :: headers(), response_body :: body()}
              | {:error, term()}

  @optional_callbacks [child_spec: 0]
end
