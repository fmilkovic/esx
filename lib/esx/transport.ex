defmodule ESx.Transport do
  defstruct [
    url: "http://127.0.0.1:9200",
    transport: HTTPoison, # TODO: More
    method: "GET",
    trace: true,
  ]

  # @type t :: %__MODULE__{method: String.t, transport: HTTPoison.t, trace: String.t}

  def transport(args \\ %{}) do
    struct %__MODULE__{}, args
  end

  def perform_request(%__MODULE__{} = ts, method, path, _params \\ %{}, body \\ nil) do
    method = if "GET" == method && body, do: ts.method, else: method

    uri = URI.merge(ts.url, path) |> URI.to_string
    body = if body, do: Poison.encode!(body), else: ""
    headers = [{"content-type", "application/json"}]

    if ts.trace, do: traceout method, uri, body

    case method do
      "GET"    -> ts.transport.request :get,    uri, body, headers
      "PUT"    -> ts.transport.request :put,    uri, body, headers
      "POST"   -> ts.transport.request :post,   uri, body, headers
      "HEAD"   -> ts.transport.request :head,   uri, body, headers
      "DELETE" -> ts.transport.request :delete, uri, body, headers
      method   -> {:error, %ArgumentError{message: "Method #{method} not supported"}}
    end
  end
  def perform_request!(%__MODULE__{} = ts, method, path, params \\ %{}, body \\ nil) do
    case perform_request(ts, method, path, params, body) do
      {:ok, rs} -> rs
      {:error, err} -> raise err
    end
  end

  defp traceout(out) when is_binary(out) do
    IO.puts out
  end
  defp traceout(method, uri, "") do
    traceout "curl -X #{method} '#{uri}'\n"
  end
  defp traceout(method, uri, body) do
    traceout "curl -X #{method} '#{uri}' -d '#{JSX.prettify! body}'\n"
  end

end
