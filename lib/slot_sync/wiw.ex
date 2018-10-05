defmodule SlotSync.WIW do
  @moduledoc """

  Makes API requests to WIW to get shift data
  Then passes response on to be processed by Dispatcher

  https://api.wheniwork.com/2/shifts?start=2016-08-07T13:00:00&end=2016-08-07T14:00:00
  headers
  W-Token: abc123

  https://api.wheniwork.com/2/shifts?start=2018-10-07&end=2018-10-08
  """

  alias SlotSync.Dispatcher
  import Logger, only: [info: 1]

  use Confex, otp_app: :slot_sync

  @wiw_base "https://api.wheniwork.com/2"

  @spec shifts(binary(), binary()) :: :ok
  def shifts(start_date, end_date) do
    # stats("wiw.get")
    info("#{__MODULE__} getting shifts between #{inspect(start_date)} and #{inspect(end_date)}")

    ("/shifts?start=" <> start_date <> "&end=" <> end_date)
    |> http_get()
    |> process_response_body()
    |> Dispatcher.chunk_response()
  end

  defp process_response_body({:ok, body}) do
    body.body
    |> Poison.decode!()
  end

  defp http_get(path), do: http_adaptor().get(@wiw_base <> path, headers())
  defp http_adaptor, do: config()[:http_adaptor]
  defp headers, do: ["W-Token": key()]
  # defp headers(), do: ["W-Key": @key()]
  # session.headers['W-Key'] = W_KEY
  # session.headers['W-UserId'] = wiw_owner_user_id

  defp key, do: config()[:key]

  # defp stats(name), do: DogStatsd.increment(:datadogstatsd, name)
end
