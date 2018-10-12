defmodule SlotSync.Runner do
  @moduledoc """
  Ensures sync peroid covers a rolling amount of data on each call

  config :slot_sync, SlotSync.Runner,
    days_ahead: 7,
    days_prior: 0
  """

  use Confex, otp_app: :slot_sync

  @spec start() :: :ok
  def start do
    now = Timex.now()
    state_data = Timex.shift(now, days: days_prior()) |> DateTime.to_iso8601()
    end_date = Timex.shift(now, days: days_ahead()) |> DateTime.to_iso8601()

    SlotSync.WIW.shifts(state_data, end_date)

    :ok
  end

  defp days_ahead(), do: config()[:days_ahead]
  defp days_prior(), do: config()[:days_prior]
end
