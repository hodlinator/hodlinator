# `perf` usage on Linux

## Tune system for profiling

Command recommended by bench_bitcoin:
```shell
pyperf system tune
```

## Configure kernel to allow sufficient sample rate

Then make sure we allow a sufficient sample rate (I didn't experiment with these numbers, maybe 140 is enough).
```shell
doas sysctl -w kernel.perf_cpu_time_max_percent=1
kernel.perf_cpu_time_max_percent = 1
doas sysctl -w kernel.perf_event_max_sample_rate=10000
kernel.perf_event_max_sample_rate = 10000
```

## Embed build-id in binaries

This is done so that perf-related tools like Hotspot can match up recorded profiling data with the correct debug symbols.

Set CMake's `APPEND_LDFLAGS=-Wl,--build-id=sha1` and re-link.

Archive the new binary which now contains a build-id:
```shell
perf buildid-cache -va ./build/bin/bitcoind
```
This puts a copy of the binary in *~/.debug/*.

## Record

Record profiling data from already running *bitcoind*:
```shell
doas perf record -g --call-graph dwarf --per-thread -F 140 -p `pgrep bitcoind` -- sleep 60
```

## Analyze

```shell
doas chown hodlinator:users perf.data && mv perf.data perf-$(git rev-parse --short=12 HEAD).data
hotspot perf-$(git rev-parse --short=12 HEAD).data
```
