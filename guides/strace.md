# `strace` usage

Useful for checking what syscalls a process is making, getting hints for why it's taking so long etc.

First attempt:
```shell
doas strace -p $(pgrep bitcoind)
```
Output is very boring, since we are only tracing the main bitcoind thread, where it is not doing any work.

* `-ff` - Trace all threads (doesn't mean we only latch onto forks/threads as they are spawned as I initially assumed).
* `-tt` - Microsecond precision.
* `-T` - Show time spent in syscalls.
```shell
doas strace -p $(pgrep bitcoind) -ffttT
```
