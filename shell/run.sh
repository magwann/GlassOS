#!/bin/sh
# GlassOS: configure (first time only), build, and run — all in one.
# Usage:  ./run.sh
set -e
cd "$(dirname "$0")"

[ -d build ] || cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build

# run nested in labwc if we're not already in a Wayland session
if [ -z "$WAYLAND_DISPLAY" ]; then
    labwc -s ./build/glassos-shell
else
    ./build/glassos-shell
fi
