# Bitcoin Core Guix builds

This is incomplete and meant to stop me re-inventing the wheel.

## Start build

Assumes one has created `$HOME/guix/`-subdirs. Remove `HOSTS`-entries below to only build relevant targets.
```shell
env -i HOME="$HOME" PATH="$PATH" USER="$USER" SOURCES_PATH="$HOME/guix/sources" \
    BASE_CACHE="$HOME/guix/cache" SDK_PATH="$HOME/guix/SDKs" \
    CCACHE_BASEDIR="$HOME" CCACHE_MAXSIZE="50G" CCACHE_DIR="$HOME/.cache/ccache" \
    HOSTS="x86_64-linux-gnu arm-linux-gnueabihf aarch64-linux-gnu riscv64-linux-gnu powerpc64-linux-gnu powerpc64le-linux-gnu x86_64-w64-mingw32 x86_64-apple-darwin arm64-apple-darwin" \
    ./contrib/guix/guix-build
```

## Share result

Guix SHA256 sum output blobs are commonly shared via GitHub comments. Replicate them through:
```shell
find guix-build-$(git rev-parse --short=12 HEAD)/output/ -type f -print0 | env LC_ALL=C sort -z | xargs -r0 sha256sum
```
