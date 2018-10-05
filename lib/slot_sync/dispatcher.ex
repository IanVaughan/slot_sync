defmodule SlotSync.Dispatcher do
  @moduledoc """
  Routes data from incoming payload into isolated messages to a dedicated processor.

  Incoming payloads from WIW have various keys of data in
  ["end", "locations", "positions", "shifts", "sites", "start", "users"]
  We might proess the others, but for now just process shifts
  """

  import Logger, only: [debug: 1]

  def chunk_response(response), do: response |> send_each()

  defp send_each(items, key \\ :main), do: items |> Enum.each(fn item -> send_one(key, item) end)

  defp send_one(:main, {"start", _start}), do: nil
  defp send_one(:main, {"end", _start}), do: nil
  defp send_one(:main, {"shifts", shifts}), do: send_each(shifts, :shift)
  defp send_one(:main, {_, _}), do: nil

  defp send_one(:shift, item), do: SlotSync.Processor.Shift.process(item)
end
