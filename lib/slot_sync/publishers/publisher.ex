defmodule SlotSync.Publishers.Kafka do
  @moduledoc """
  Formats and encodes the payload and the publishes it to Kafka
  """
  use Confex, otp_app: :slot_sync

  alias SlotSync.TrackingLocationsFormatter
  alias KafkaEx.Protocol.Produce.Request
  alias KafkaEx.Protocol.Produce.Message
  require Logger

  # @type key() :: String.t()
  # @type event() :: String.t()
  # @type topic_name() :: String.t() | atom()
  # @type encoded_message() :: String.t()

  @doc """
  This is the main function to trigger a message to be published to Kafka

  ## Examples

  """

  # @type message_number() :: integer()
  # @spec call(map(), integer(), topic_name()) :: {:ok, message_number()} | {:error, String.t()}
  def call(data, id) do
    id
    |> build_event_key()
    |> encode_event_message(data)
    |> build_request(data)
    |> publish()
  end

  defp build_event_key(id), do: [{"id", id}]

  # @spec encode_event_message(key, event, topic_name) ::
  #         {:encoded_key, encoded_message, encoded_message: encoded_message} | {:error, key}
  defp encode_event_message(key, event) do
    with {:ok, encoded_key} <- encoder().call(key_schema_name(), key),
         {:ok, encoded_message} <- encoder().call(value_schema_name(), transformed(event)) do
      %{encoded_key: encoded_key, encoded_message: encoded_message}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp transformed(event) do
    event["linked_users"] |> IO.inspect(label: "linked_users")

    [
      {"account_id", event["account_id"]},
      {"acknowledged", event["acknowledged"]},
      {"acknowledged_at", string_or_nil(event["acknowledged_at"])},
      {"actionable", event["actionable"]},
      {"alerted", event["alerted"]},
      {"block_id", event["block_id"]},
      {"break_time", event["break_time"]},
      {"color", event["color"]},
      {"created_at", event["created_at"]},
      {"creator_id", event["creator_id"]},
      {"end_time", event["end_time"]},
      {"id", event["id"]},
      {"instances", event["instances"]},
      {"is_open", event["is_open"]},
      # {"linked_users", event["linked_users"]},
      {"linked_users", :null},
      {"location_id", event["location_id"]},
      {"notes", event["notes"]},
      {"notified_at", string_or_nil(event["notified_at"])},
      {"position_id", event["position_id"]},
      {"published", event["published"]},
      {"published_date", event["published_date"]},
      {"shiftchain_key", event["shiftchain_key"]},
      {"site_id", event["site_id"]},
      {"start_time", event["start_time"]},
      {"updated_at", event["updated_at"]},
      {"user_id", event["user_id"]}
    ]
  end

  defp string_or_nil(_), do: {"null", :null}
  defp string_or_nil(value), do: {"string", value}

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
