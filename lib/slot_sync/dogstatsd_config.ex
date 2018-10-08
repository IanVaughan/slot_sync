defmodule SlotSync.DogStatsdConfig do
  @moduledoc """
  Helper to get DogStatsd setup correctly
  """
  def configs do
    host = Confex.get_env(:slot_sync, SlotSync.Datadog)[:host]
    port = Confex.get_env(:slot_sync, SlotSync.Datadog)[:port]
    namespace = Confex.get_env(:slot_sync, SlotSync.Datadog)[:namespace]

    %{:host => host, :port => port, :namespace => namespace}
  end
end
