defmodule ESx.API do
  import ESx.API.R

  alias ESx.API.Utils
  alias ESx.Transport

  def info(%Transport{} = ts, _args \\ %{}) do
    {method, path, params, body} = blank_args

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end
  def info!(%Transport{} = ts, _args \\ %{}) do
    info(ts)
    |> response!
  end

  def ping(%Transport{} = ts, _args \\ %{}) do
    {method, path, params, body} = blank_args

    status200? ts, method, path, params, body
  end

  def ping!(%Transport{} = ts, _args \\ %{}) do
    case ping(ts) do
      rs when is_boolean(rs) ->
        rs
      {:error, err} ->
        raise err
    end
  end

  def index(%Transport{} = ts, %{index: index, type: type} = args) do
    method = if args[:id], do: "PUT", else: "POST"
    path   = Utils.pathify [Utils.escape(index), Utils.escape(type), Utils.escape(args[:id])]
    params = %{}
    body   = args[:body]

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def search(%Transport{} = ts, args \\ %{}) do
    args =
      if !args[:index] && args[:type] do
        Map.put args, :index, "_all"
      else
        args
      end

    method = "GET"
    path   = Utils.pathify([Utils.listify(args[:index]), Utils.listify(args[:type]), "_search"])
    params = %{}
    body   = args[:body]

    Transport.perform_request(ts, method, path, params, body)
    |> response
  end

  def search!(%Transport{} = ts, args \\ %{}) do
    search(ts, args)
    |> response!
  end
end
