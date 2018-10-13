defmodule SlotSync.Publishers.Kafka do
  @moduledoc """
  Formats and encodes the payload and the publishes it to Kafka
  """
  use Confex, otp_app: :slot_sync

  alias KafkaEx.Protocol.Produce.Request
  alias KafkaEx.Protocol.Produce.Message
  require Logger

  @type key() :: String.t()
  @type event() :: String.t()
  @type encoded_message() :: String.t()

  @doc """
  This is the main function to trigger a message to be published to Kafka
  """

  @type message_number() :: integer()
  @spec call(map(), integer()) :: {:ok, message_number()} | {:error, String.t()}
  def call(data, id) do
    id
    |> build_event_key()
    |> encode_event_message(data)
    |> build_request(data)
    |> publish()
  end

  defp build_event_key(id), do: [{"id", id}]

  @spec encode_event_message(key, event) ::
          {:encoded_key, encoded_message, encoded_message: encoded_message} | {:error, key}
  defp encode_event_message(key, event) do
    with {:ok, encoded_key} <- encoder().call(key_schema_name(), key),
         {:ok, encoded_message} <- encoder().call(value_schema_name(), event) do
      %{encoded_key: encoded_key, encoded_message: encoded_message}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp build_request({:error, error}, event) do
    stats("publisher.encoding.error")
    Logger.warn("Failed to decode event:#{inspect(event)}, error:#{inspect(error)}")
    {:error, error}
  end

  defp build_request(%{encoded_key: encoded_key, encoded_message: encoded_message}, _event) do
    stats("publisher.encoding.success")

    messages = [%Message{key: encoded_key, value: encoded_message}]

    {:ok,
     %Request{
       topic: topic_name(),
       partition: 0,
       required_acks: 1,
       messages: messages
     }}
  end

  defp publish({:error, error}), do: {:error, error}
  defp publish({:ok, request}), do: request |> kafka_client().produce()
  defp kafka_client(), do: config()[:kafka_client]

  defp key_schema_name, do: topic_name() <> "-key"
  defp value_schema_name, do: topic_name() <> "-value"

  defp topic_name, do: config()[:topic_name]

  defp encoder(), do: config()[:event_serializer_encoder]

  defp stats(name), do: DogStatsd.increment(:datadogstatsd, name)
end
