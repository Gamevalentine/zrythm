#!/usr/bin/env bash
# SPDX-FileCopyrightText: © 2026 ORVIA / LUNOR MUSIC contributors
# SPDX-License-Identifier: LicenseRef-ZrythmLicense
#
# Compile the *original Zrythm source* to WebAssembly with Qt/QML.
# This is a source-port feasibility test: no fake HTML, no remote desktop.
# Failure is an expected, actionable result until native-only libraries are ported.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${QT_WASM_PREFIX:?Set QT_WASM_PREFIX to the matching Qt 6.11.1 WebAssembly installation}"
: "${QT_HOST_PATH:?Set QT_HOST_PATH to the matching Qt 6.11.1 host tools installation}"

echo "[ORVIA WASM] Original source: $ROOT"
echo "[ORVIA WASM] Qt WebAssembly: $QT_WASM_PREFIX"
echo "[ORVIA WASM] Qt host tools: $QT_HOST_PATH"

for cmd in emcc emcmake em++ cmake ninja; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf '[ORVIA WASM][BLOCKED] Missing build tool: %s\n' "$cmd" >&2
    exit 2
  fi
done

emcc --version | head -n 1
cmake --version | head -n 1

for requirement in \
  "$QT_WASM_PREFIX/lib/cmake/Qt6/Qt6Config.cmake" \
  "$QT_WASM_PREFIX/lib/cmake/Qt6CanvasPainter/Qt6CanvasPainterConfig.cmake" \
  "$QT_HOST_PATH/lib/cmake/Qt6/Qt6Config.cmake"; do
  if [[ ! -f "$requirement" ]]; then
    printf '[ORVIA WASM][BLOCKED] Missing SDK component: %s\n' "$requirement" >&2
    exit 2
  fi
done

echo '[ORVIA WASM] Qt WebAssembly + CanvasPainter SDK found.'
BUILD_DIR="${ORVIA_WASM_BUILD_DIR:-$ROOT/build/orvia-webwasm}"

# Configure against Zrythm's actual root CMake project. It may fail because
# Conan/CPM dependencies, native JUCE hardware, LV2 and VST3 host code are not
# WebAssembly-compatible yet. Report the first real failure, never build a mock.
echo '[ORVIA WASM] Starting ORIGINAL Zrythm CMake configure.'
emcmake cmake -S "$ROOT" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$QT_WASM_PREFIX" \
  -DQT_HOST_PATH="$QT_HOST_PATH" \
  -DZRYTHM_TESTS=OFF \
  -DZRYTHM_QML_TESTS=OFF \
  -DZRYTHM_BENCHMARKS=OFF \
  -DZRYTHM_USER_MANUAL=OFF

echo '[ORVIA WASM] Building original Zrythm application target.'
cmake --build "$BUILD_DIR" --target zrythm --parallel "${ORVIA_BUILD_JOBS:-2}"
echo '[ORVIA WASM] Native source compilation finished; browser GUI/audio require separate runtime QA.'
