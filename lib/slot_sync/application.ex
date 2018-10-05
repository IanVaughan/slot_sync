defmodule SlotSync.Application do
  use Application
  use Confex, otp_app: :slot_sync

  import Supervisor.Spec

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SlotSync.Supervisor]

    Supervisor.start_link(children(), opts)
  end

  defp children do
    with conf <- Map.new(config()) do
      [:shift_processor] |> Enum.flat_map(&children(&1, conf))
    end
  end

  defp children(:shift_processor, _) do
    [
      worker(SlotSync.Processor.Shift, [])
    ]
  end
end
