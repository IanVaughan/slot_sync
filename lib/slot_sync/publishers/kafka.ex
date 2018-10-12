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
         {:ok, encoded_message} <- encoder().call(value_schema_name(), transformed(event)) do
      %{encoded_key: encoded_key, encoded_message: encoded_message}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp transformed(event) do
    [
      {"account_id", event["account_id"]},
      {"acknowledged", event["acknowledged"]},
      {"acknowledged_at", event["acknowledged_at"] |> string_or_nil() |> date_to_iso()},
      {"actionable", event["actionable"]},
      {"alerted", event["alerted"]},
      {"block_id", event["block_id"]},
      {"break_time", event["break_time"]},
      {"color", event["color"]},
      {"created_at", event["created_at"] |> date_to_iso()},
      {"creator_id", event["creator_id"]},
      {"end_time", event["end_time"] |> date_to_iso()},
      {"id", event["id"]},
      {"instances", event["instances"]},
      {"is_open", event["is_open"]},
      # {"linked_users", event["linked_users"]},
      {"linked_users", :null},
      {"location_id", event["location_id"]},
      {"notes", event["notes"]},
      {"notified_at", event["notified_at"] |> string_or_nil() |> date_to_iso()},
      {"position_id", event["position_id"]},
      {"published", event["published"]},
      {"published_date", event["published_date"] |> date_to_iso()},
      {"shiftchain_key", event["shiftchain_key"]},
      {"site_id", event["site_id"]},
      {"start_time", event["start_time"] |> date_to_iso()},
      {"updated_at", event["updated_at"] |> date_to_iso()},
      {"user_id", event["user_id"]}
    ]
  end

  defp string_or_nil(_), do: {"null", :null}
  defp string_or_nil(value), do: {"string", value}

  # WIW dates are formatted as "Wed, 26 Sep 2018 12:30:28 +0100"
  # But we want iso8601, eg: "2018-09-26T12:30:28+01:00"
  defp date_to_iso(nil), do: nil

  defp date_to_iso(date_string) do
    with {:ok, time} <- Timex.parse(date_string, "{RFC1123}") do
      DateTime.to_iso8601(time)
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
