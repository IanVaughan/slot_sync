defmodule SlotSync.Application do
  use Application
  use Confex, otp_app: :slot_sync

  import Supervisor.Spec
  require DogStatsd

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SlotSync.Supervisor]

    app = Supervisor.start_link(children(), opts)

    DogStatsd.event(:datadogstatsd, "slot_sync is starting", "node: #{node()}", %{
      tags: ["application_start"]
    })

    app
  end

  defp children do
    with conf <- Map.new(config()) do
      [:metrics_service, :shift_processor, :wiw_sync] |> Enum.flat_map(&children(&1, conf))
    end
  end

  defp children(:metrics_service, _) do
    [
      supervisor(DogStatsd, [
        SlotSync.DogStatsdConfig.configs(),
        [name: :datadogstatsd]
      ])
    ]
  end

  defp children(:shift_processor, _) do
    [
      worker(SlotSync.Processor.Shift, [])
    ]
  end

  defp children(:wiw_sync, _) do
    [
      # Run every five minutes
      %{
        id: "frequent",
        start: {SchedEx, :run_every, [SlotSync.Runner, :start, [], "*/5 * * * *"]}
      }
    ]
  end
end
