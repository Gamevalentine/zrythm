#!/usr/bin/env bash
# SPDX-FileCopyrightText: © 2026 ORVIA / LUNOR MUSIC contributors
# SPDX-License-Identifier: LicenseRef-ZrythmLicense
#
# ORVIA: build the original Zrythm source with Qt 6.11 + Emscripten.
# The script intentionally does not generate an HTML mock or show screenshots.
# It fails if browser-compatible dependencies are not available.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
: "${QT_WASM_PREFIX:?Please provide the Qt 6.11+ WebAssembly SDK prefix in QT_WASM_PREFIX}"
: "${QT_HOST_PATH:?Please provide the matching native Qt host installation in QT_HOST_PATH}"

for cmd in emcmake em++ cmake ninja; do
  command -v "$cmd" >/dev/null 2>&1 || {
    printf 'ORVIA Web: missing %s. Native Zrythm cannot run directly in a browser.\n' "$cmd" >&2
    exit 2
  }
done

if [[ ! -f "$QT_WASM_PREFIX/lib/cmake/Qt6/Qt6Config.cmake" ]]; then
  printf 'ORVIA Web: Qt6 Wasm package not found in %s\n' "$QT_WASM_PREFIX" >&2
  exit 2
fi

# Zrythm currently requires CanvasPainter (Qt 6.11); report missing Wasm
# support as a blocker rather than replacing its original QML interface.
if [[ ! -f "$QT_WASM_PREFIX/lib/cmake/Qt6CanvasPainter/Qt6CanvasPainterConfig.cmake" ]]; then
  printf 'ORVIA Web: Qt CanvasPainter WebAssembly library is unavailable. Build is blocked.\n' >&2
  exit 2
fi

BUILD_DIR="${ORVIA_WASM_BUILD_DIR:-$ROOT/build/orvia-webwasm}"
mkdir -p "$BUILD_DIR"

echo '[ORVIA Web] Configuring the original Zrythm C++/Qt/QML application; no fake frontend.'
emcmake cmake -S "$ROOT" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$QT_WASM_PREFIX" \
  -DQT_HOST_PATH="$QT_HOST_PATH" \
  -DZRYTHM_TESTS=OFF \
  -DZRYTHM_QML_TESTS=OFF \
  -DZRYTHM_BENCHMARKS=OFF \
  -DZRYTHM_USER_MANUAL=OFF

echo '[ORVIA Web] Compiling actual Zrythm GUI target (blocked native-only dependencies must be ported).'
cmake --build "$BUILD_DIR" --target zrythm --parallel "${ORVIA_BUILD_JOBS:-2}"
echo '[ORVIA Web] Build finished. Browser runtime and audio are NOT verified by a successful compile.'
