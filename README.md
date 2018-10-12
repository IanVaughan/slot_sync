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
