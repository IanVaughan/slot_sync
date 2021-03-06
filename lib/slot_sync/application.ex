defmodule SlotSync.Application do
  use Application
  use Confex, otp_app: :slot_sync

  import Supervisor.Spec
  import SlotSync.KafkaConfig
  require DogStatsd

  @spec start(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SlotSync.Supervisor]

    app = Supervisor.start_link(children(), opts)

    DogStatsd.event(:datadogstatsd, "slot_sync is starting", "node: #{node()}", %{
      tags: ["application_start"]
    })

    if config()[:start_workers] do
      KafkaEx.create_worker(:kafka_ex, uris: brokers())
    end

    app
  end

  defp children do
    with conf <- Map.new(config()) do
      [:metrics_service, :shift_processor, :redis, :wiw_sync]
      |> Enum.flat_map(&children(&1, conf))
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
      worker(SlotSync.Runner, [])
    ]
  end

  defp children(:redis, _) do
    [
      worker(SlotSync.Cache.Redis, [])
    ]
  end
end
