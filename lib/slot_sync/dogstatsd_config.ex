defmodule SlotSync.DogStatsdConfig do
  # require Logger

  def configs do
    # [:host, :port, :namespace, :tags, :max_buffer_size]

    host = Confex.get_env(:slot_sync, SlotSync.Datadog)[:host]
    port = Confex.get_env(:slot_sync, SlotSync.Datadog)[:port]
    namespace = Confex.get_env(:slot_sync, SlotSync.Datadog)[:namespace]

    %{:host => host, :port => port, :namespace => namespace}
  end
end
