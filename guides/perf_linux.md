# `perf` usage on Linux

## Tune system for profiling

Command recommended by bench_bitcoin:
```shell
pyperf system tune
```

## Configure kernel to allow sufficient sample rate

Then make sure we allow a sufficient sample rate (I didn't experiment with these numbers, sample rate of 140 could be enough).
```shell
doas sysctl -w kernel.perf_cpu_time_max_percent=1
doas sysctl -w kernel.perf_event_max_sample_rate=10000
doas sysctl -w kernel.perf_event_paranoid=-1
doas sysctl -w kernel.kptr_restrict=0
```

## Embed build-id in binaries

This is done so that analysis tools can match up recorded profiling data with the correct debug symbols.

Set CMake's `APPEND_LDFLAGS=-Wl,--build-id=sha1` and re-link.

This is enough to make `perf record` below put a copy of the binary in *~/.debug/*.

## Record

Record profiling data from already running *bitcoind*:
```shell
perf record -g --call-graph dwarf --per-thread -F 140 -p `pgrep bitcoind` --output=perf-`git rev-parse --short=12 HEAD`.data -- sleep 60
```

## Analyze

```shell
hotspot perf-$(git rev-parse --short=12 HEAD).data
```
or
```shell
perf report --input=perf-$(git rev-parse --short=12 HEAD).data
```
