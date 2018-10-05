defmodule SlotSync.Runner do
  @moduledoc """
  Will schedule running covering a days worth of data on each call
  """
  @spec start() :: :ok
  def start do
    now = Timex.now()
    state_data = Timex.shift(now, days: -1)
    end_date = Timex.shift(now, days: 1)

    SlotSync.WIW.shifts(state_data, end_date)

    :ok
  end
end
