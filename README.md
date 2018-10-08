# Slot Sync

A tool for reading data from a third party via their API and publishing to a broker.

## Overview

* Currently sync's slot data from WIW
* Runs sync every 5 minutes (see SchedEx for :wiw_sync to change)
* Caches the data locally in Redis
* If newly read data has changed from cached version it then publishes to Kafka

## Detail
```
(every 5 minutes)
|> SlotSync.Runner
|> SlotSync.WIW
  |> 1 days worth of shifts from today
  |> get slots on WIW
|> SlotSync.Dispatcher
  |> each shift
|> SlotSync.Processor.Shift (GenServer)
  |> if matches redis cache then next (cache expires each slot after 1 week)
  |> if not then save in redis and publish
|> SlotSync.Publishers.Kafka
```
