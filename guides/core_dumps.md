# Core Dumps

## Linux

Core dumps (https://man7.org/linux/man-pages/man5/core.5.html) are dumped according to:
```shell
$ cat /proc/sys/kernel/core_pattern
|/nix/store/xfrvwv9jabaq55q60162n1qsa4s1azdb-systemd/lib/systemd/systemd-coredump %P %u %g %s %t %c %h %d %F
```
SystemD puts dumps in:
```
ls /var/lib/systemd/coredump/
```

## Windows

Dumps can be generated using the ProcDump tool (https://learn.microsoft.com/en-us/sysinternals/downloads/procdump).

I once made a temporary change for CI to upon detecting a bitcoind stall:

* Download the ProcDump tool.
* Produce a .dmp file.
* Create a CI artifact for analysis.

That work was done under https://github.com/bitcoin/bitcoin/pull/30956 and the fix was implemented in https://github.com/bitcoin/bitcoin/pull/31124.
