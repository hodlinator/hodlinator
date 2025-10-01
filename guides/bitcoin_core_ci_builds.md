# Bitcoin Core CI builds (locally)

## Example: Linux->Windows cross

On Linux, building using a container and then fetching the binaries to test on Windows:

* Modify `ci/test/02_run_container.sh` to not `docker container kill` itself at the end.
* Run
  ```shell
  env -i HOME="$HOME" PATH="$PATH" USER="$USER" bash -c 'MAKEJOBS="-j$(nproc)" FILE_ENV="./ci/test/00_setup_env_win64.sh" ./ci/test_run_all.sh'
  ```
* (Inspect container through `docker exec -it ci_win64 bash` to see file layout).
* Copy binaries out from the container (`docker cp ci_win64:/ci_container_base/ci/scratch/build-x86_64-w64-mingw32/bin/bitcoind.exe .`).
* Run binaries on Windows.

## Example: clang-tidy job

```shell
env -i HOME="$HOME" PATH="$PATH" USER="$USER" bash -c 'MAKEJOBS="-j$(nproc)" FILE_ENV="./ci/test/00_setup_env_native_tidy.sh" ./ci/test_run_all.sh'
```