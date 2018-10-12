use Mix.Config
config :logger, level: :debug

config :slot_sync, SlotSync.Application, start_workers: false

config :event_serializer, enabled: false
