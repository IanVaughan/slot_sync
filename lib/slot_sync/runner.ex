defmodule SlotSync.Runner do
  @moduledoc """
  Ensures sync period covers a rolling amount of data on each call
  Then sleeps for a configuable amount of time before running the sync again

  Config:

  ```elixir
  config :slot_sync, SlotSync.Runner,
    days_ahead: {:system, "SYNC_DAYS_AHEAD", 1},
    days_prior: {:system, "SYNC_DAYS_PRIOR", 0},
    sleep_for_seconds: {:system, "SYNC_SLEEP_PERIOD_SECONDS", 10}
  ```

  """

  use Confex, otp_app: :slot_sync
  require Logger

  use GenServer

  @impl true
  @spec start_link() :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link, do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  # Callbacks

  @impl true
  @spec init(any()) :: {:ok, pid()}
  def init(_) do
    Process.send_after(__MODULE__, :start, 0)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:start, state) do
    run()
    Process.send_after(__MODULE__, :start, sleep_for_seconds())

    {:noreply, state}
  end

  @spec run() :: :ok
  defp run do
    now = Timex.now()
    state_data = Timex.shift(now, days: days_prior()) |> DateTime.to_iso8601()
    end_date = Timex.shift(now, days: days_ahead()) |> DateTime.to_iso8601()

    SlotSync.WIW.shifts(state_data, end_date)

    :ok
  end

  defp sleep_for_seconds, do: config()[:sleep_for_seconds] * 1000
  defp days_ahead, do: config()[:days_ahead]
  defp days_prior, do: config()[:days_prior]
end
