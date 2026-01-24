# Tips for developing / testing Bitcoin Core on Windows

From Visual Studio "x86 Native Tools..." cmd prompt:
```
cd \Users\hodlinator\bitcoin
```

Disable UI to avoid slow-to-build Qt dependencies:
```
cmake -B build --preset vs2022 -DVCPKG_INSTALL_OPTIONS="--x-buildtrees-root=C:\vcpkg" -DBUILD_GUI=OFF -DVCPKG_MANIFEST_NO_DEFAULT_FEATURES=ON -DVCPKG_MANIFEST_FEATURES="wallet;tests" -DWITH_ZMQ=OFF
cmake --build build --config Release -j16
```

May be needed (especially in Debug?):
```diff
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -278,6 +278,7 @@ if(WIN32)
       /Zc:preprocessor
       /Zc:__cplusplus
       /sdl
+      /bigobj
     )
     target_link_options(core_interface INTERFACE
       # We embed our own manifests.
```

You may want to add exclusions under Settings -> Virus & Threat Protection for these, even if it opens up attack vectors à la NPM:
* `C:\Users\<username>\AppData\Local\vcpkg`
* `C:\Users\<username>\bitcoin` (whatever directory your git repo is in)
* `C:\vcpkg`

Set proper charmap/codepage for Bash/Python:
```shell
export PYTHONUTF8=1
```

Make sure you are testing what you've been editing, CMake falls back to copying test files when it thinks symlinks are not supported:
```
copy /y .\test\functional\wallet_multiwallet.py .\build\test\functional\wallet_multiwallet.py && .\build\test\functional\wallet_multiwallet.py
```

Swap between native builds and cross-built:
```
copy /y build\bin\Release\bitcoind.exe build\bin\bitcoind.exe
```
```
copy /y build\bin\bitcoind-msvcrt-release.exe build\bin\bitcoind.exe
```

Use [SHIFT]+[INSERT] to paste in Windows "Git Bash" prompts to avoid weird characters from [CTRL]+[V].
