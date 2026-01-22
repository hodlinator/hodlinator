# Tips for developing / testing Bitcoin Core on Windows

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
