defmodule SlotSync.Message do
  @moduledoc """
  Formats a payload into a kafka ready message
  """
  def format(event) do
    [
      {"account_id", event["account_id"]},
      {"acknowledged", event["acknowledged"]},
      {"acknowledged_at", event["acknowledged_at"] |> date_to_iso() |> string_or_nil()},
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
      {"notified_at", event["notified_at"] |> date_to_iso() |> string_or_nil()},
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

  defp string_or_nil(nil), do: {"null", :null}
  defp string_or_nil(value), do: {"string", value}

  # WIW dates are formatted as "Wed, 26 Sep 2018 12:30:28 +0100"
  # But we want iso8601, eg: "2018-09-26T12:30:28+01:00"
  # UTC w/out timezone info
  defp date_to_iso(nil), do: nil

  defp date_to_iso(date_string) do
    with {:ok, time} <- Timex.parse(date_string, "{RFC1123}") do
      DateTime.to_iso8601(time)
    end
  end
end
