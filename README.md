# Slot Sync

[![Build Status](https://travis-ci.org/quiqupltd/slot_sync.svg?branch=master)](https://travis-ci.org/quiqupltd/slot_sync)

A tool for reading data from a third party via their API and publishing to a broker.

## Overview

```
(every X minutes)
|> SlotSync.Runner
|> SlotSync.WIW
  |> Y days worth of shifts either side of today
  |> get slots on WIW
|> SlotSync.Dispatcher
  |> each shift
|> SlotSync.Processor.Shift (GenServer)
  |> if matches redis cache then next (cache expires each slot after 1 week)
  |> if not then save in redis and publish
|> SlotSync.Publishers.Kafka
```

## Config

The follow env variables can be set, some are required.

### SlotSync.Runner

* `SYNC_DAYS_AHEAD` - default: 1 - How many days ahead from today to get data for
* `SYNC_DAYS_PRIOR` - default: 0 - How many days before today to get data for
* `SYNC_SLEEP_PERIOD_SECONDS` - default: 10 - How long to wait before the next sync
    * NOTE: This waits from the time the sync finishes, so is not a fully correct game loop
    * Eg if the sync takes 2 seconds, with the default 10, it will sync every 12 seconds

### WIW Sync

* `WIW_KEY` - The key to use in the header for WIW API requests

### Kafka

* `KAFKA_BROKERS` - Required - A list of kafka hosts to publish data to
* `KAFKA_TOPIC_NAME` - Required - The name of the topic to publish each shift payload to

### Kafka Schemas

You might already have the Kafka schemas setup, but if not, `ktsllex` can perform the schema "migrations" for you.

See ktsllex (https://github.com/quiqupltd/ktsllex/) for more info.

### Schema encoding

To encode messages into a Avro schema we use `event_serializer` (https://github.com/quiqupltd/event_serializer)

* `AVLIZER_CONFLUENT_SCHEMAREGISTRY_URL` - Required

### Cache

Each shift downloaded is cached in Redis to compare against on the next sync run.

* `REDIS_HOST` - default: "redis://localhost:6379"
* `EXPIRE_CACHE` - default: 604_800 (1 week)

### Monitoring

Each sync and publish success or fail event is emitted to Datadog

* `STATSD_HOST` - Required
* `STATSD_PORT` - Default: 8125