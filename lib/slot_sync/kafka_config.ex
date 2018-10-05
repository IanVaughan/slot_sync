defmodule SlotSync.KafkaConfig do
  require Logger

  def brokers do
    :slot_sync
    |> Confex.get_env(:brokers)
    |> brokers()
    |> IO.inspect(label: "brokers")
  end

  defp brokers(nil), do: nil
  defp brokers(list) when is_list(list), do: list

  defp brokers(value) when is_binary(value) do
    for line <- String.split(value, ","), into: [] do
      case line |> String.trim() |> String.split(":") do
        [host] ->
          msg = "Port not set for kafka broker #{host}"
          Logger.warn(msg)
          raise msg

        [host, port] ->
          {port, _} = Integer.parse(port)
          {host, port}
      end
    end
  end
end
