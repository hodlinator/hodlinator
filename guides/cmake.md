# CMake

## Useful build file generation

Enable developer mode. Disable IPC and GUI. Disable optimizations to be friendlier to debugger. Generate using Ninja since it is slightly faster than Make:
```
cmake -B build --preset dev-mode -DENABLE_IPC=OFF -DBUILD_GUI=OFF -DCMAKE_BUILD_TYPE=Debug -GNinja
```

## Build single .CPP

Useful when touching header that affects a large part of the project:
```
ninja -C build ../src/test/sigopcount_tests.cpp^
```
