Example on Linux, building using a container and then fetching the binaries to test on Windows:
* Modify `ci/test/02_run_container.sh` to not kill itself at the end.
* Run `env -i HOME="$HOME" PATH="$PATH" USER="$USER" bash -c 'MAKEJOBS="-j16" FILE_ENV="./ci/test/00_setup_env_win64.sh" ./ci/test_run_all.sh'`
* Copy binaries out from the container.
* Run binaries on Windows.

Even simpler to run clang-tidy job:
```
env -i HOME="$HOME" PATH="$PATH" USER="$USER" bash -c 'MAKEJOBS="-j16" FILE_ENV="./ci/test/00_setup_env_native_tidy.sh" ./ci/test_run_all.sh'
```