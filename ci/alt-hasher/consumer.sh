#!/usr/bin/env bash
set -euo pipefail
test "$(id -un)" = builder
module_dir=$(dirname "$(grep '/FindGeogram.cmake$' /results/geogram-devel-files.txt)")
test -f "$module_dir/FindGeogram.cmake"
cmake -S /sources/tests/standalone-text-editor -B /home/builder/consumer \
    -DGEOGRAM_INSTALL_PREFIX=/usr -DCMAKE_MODULE_PATH="$module_dir" \
    -DGEOGRAM_CHECK_GEOMETRY=ON -DGEOGRAM_CHECK_LUA=OFF
cmake --build /home/builder/consumer --parallel 4
ctest --test-dir /home/builder/consumer --output-on-failure \
    --output-junit /results/consumer-tests.xml
printf '%s\n' 'Installed Geogram/editor and OpenNL/TetGen/Triangle consumers passed.' \
    > /results/installed-consumer.ok
