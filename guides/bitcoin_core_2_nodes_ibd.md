# 2 nodes IBD

How to simply profile IBD using 2 (local?) nodes without interference from others.

## Node 1

Sync mainnet to the desired block height.

Restart with for example:
```
./build/bin/bitcoind -noconnect -listen
```

## Node 2

```
rm -rf ~/bitcoin && time ./build/bin/bitcoind -connect=<other node> -stopatheight=<desired_height> <custom parameters>
```
