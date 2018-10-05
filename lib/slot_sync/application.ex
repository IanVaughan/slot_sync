defmodule SlotSync.Application do
  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SlotSync.Supervisor]

    app = Supervisor.start_link(children(), opts)

  defp children do
    with conf <- Map.new(config()) do
      [:shift_processor] |> Enum.flat_map(&children(&1, conf))
    end
  end



  defp children(:shift_processor, _) do
    [
      worker(SlotSync.Processor.Run, [])
    ]
  end
end
