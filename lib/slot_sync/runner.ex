defmodule SlotSync.Runner do
  @moduledoc """
  Will schedule running as needed
  """
  def run do
    state_data = "2018-07-07"
    end_date = "2018-09-08"
    # now = Timex.now
    # state_data = Timex.shift(now, days: -1)
    # end_date = Timex.shift(now, days: 1)

    SlotSync.WIW.shifts(state_data, end_date)
  end
end
