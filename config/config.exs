# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

config :slot_sync, SlotSync.Application, start_workers: true

config :slot_sync, SlotSync.WIW,
  http_adaptor: HTTPoison,
  key: {:system, :string, "WIW_KEY"}

config :slot_sync, brokers: {:system, :string, "KAFKA_BROKERS", "localhost:9092"}

config :kafka_ex,
  # Dont change this value, the actual value is being set by the statement above (config :slot_sync, brokers:),
  # to bypass limitation of kafka_ex 0.8.3, which doesn't use Confex
  brokers: [{"localhost", 9092}],

  # Ensure that the schema registry url is set and the host and port are valid.
  # schema_versions: %{"com.quiqup.tracking_locations": "1"},

  # Set this value to true if you do not want the default
  # `KafkaEx.Server` worker to start during application start-up -
  # i.e., if you want to start your own set of named workers
  disable_default_worker: true,
  # Timeout value, in msec, for synchronous operations (e.g., network calls).
  # If this value is greater than GenServer's default timeout of 5000, it will also
  # be used as the timeout for work dispatched via KafkaEx.Server.call (e.g., KafkaEx.metadata).
  # In those cases, it should be considered a 'total timeout', encompassing both network calls and
  # wait time for the genservers.
  sync_timeout: 3000,
  # Supervision max_restarts - the maximum amount of restarts allowed in a time frame
  max_restarts: 10,
  # Supervision max_seconds -  the time frame in which :max_restarts applies
  max_seconds: 60,
  # Interval in milliseconds that GenConsumer waits to commit offsets.
  commit_interval: 5_000,
  # Threshold number of messages consumed for GenConsumer to commit offsets
  # to the broker.
  commit_threshold: 100,
  use_ssl: false,
  kafka_version: "1.0.1"

config :avlizer,
  avlizer_confluent: %{
    schema_registry_url:
      {:system, "AVLIZER_CONFLUENT_SCHEMAREGISTRY_URL", "http://localhost:8081"}
  }

config :event_serializer,
  schema_registry_url: {:system, "AVLIZER_CONFLUENT_SCHEMAREGISTRY_URL", "http://localhost:8081"},
  topic_name: {:system, "KAFKA_TOPIC_NAME", "uk.london.quiqup.slots"}

config :slot_sync, SlotSync.Datadog,
  host: {:system, "STATSD_HOST"},
  port: {:system, :integer, "STATSD_PORT"},
  namespace: "slot_sync",
  module: DogStatsd

config :slot_sync, SlotSync.Publishers.Kafka,
  event_serializer_encoder: EventSerializer.Encoder,
  kafka_client: KafkaEx,
  topic_name: {:system, :string, "KAFKA_TOPIC_NAME", "uk.london.quiqup.slots"}

config :slot_sync, SlotSync.Processor.Shift, publisher: SlotSync.Publishers.Kafka

config :slot_sync, SlotSync.Cache.Redis,
  redis_host: {:system, "REDIS_HOST", "redis://localhost:6379"},
  # Cached for 1 week
  expire_cache: {:system, "EXPIRE_CACHE", 604_800}

config :ktsllex,
  run_migrations: true,
  schema_registry_host: {:system, "AVLIZER_CONFLUENT_SCHEMAREGISTRY_URL", "http://localhost:8081"},
  base_path: {:system, "KAFKA_SCHEMA_BASE_PATH", "./schemas/slots"},
  schema_name: {:system, "KAFKA_SCHEMA_NAME", "uk.london.quiqup.slots"},
  app_name: :slot_sync,
  lenses_host: {:system, "LENSES_HOST", "http://localhost:3030"},
  lenses_user: {:system, "LENSES_USER", "admin"},
  lenses_pass: {:system, "LENSES_PASS", "admin"},
  lenses_topic: {:system, "LENSES_TOPIC", "uk.london.quiqup.slots"}

config :slot_sync, SlotSync.Runner,
  days_ahead: {:system, "SYNC_DAYS_AHEAD", 1},
  days_prior: {:system, "SYNC_DAYS_PRIOR", 0},
  sleep_for_seconds: {:system, "SYNC_SLEEP_PERIOD", 10}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
