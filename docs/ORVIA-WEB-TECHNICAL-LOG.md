# ORVIA WebAssembly technical log — source port (20/10/2026)

## User's actual requirement
The user wants the **real Zrythm source** (`Gamevalentine/zrythm`) **running locally in the browser on a temporary HTTPS web site**, for hands-on editing and listening during development. **Not remote desktop, screenshots, status dashboard, or a separate HTML DAW clone.** This requirement overrides the prior interpretation that the website was a static progress monitor. The desktop Windows product remains a longer-term goal.

## Source of truth / preflight
- Read shared LUNOR MUSIC Google Docs log before starting; inspected ORVIA native log and `AGENTS.md`.
- Fork base: `master` commit `4c2d47143da71ab8cb08141890e7b36fe7974312`.
- Dedicated isolated branch `feature/orvia-webassembly-port`, not using Windows branch or changing `master`.
- Qt documentation: Qt for WebAssembly supports Qt Quick/QML through Emscripten, but only selected Qt modules and OS APIs. The app's exact version is not yet browser-qualified.
- Upstream Zrythm `CMakeLists.txt` requires **Qt >=6.11** and `Qt6::CanvasPainter`. CanvasPainter (Qt 6.11) is a Technology Preview with its own GPLv3/commercial license; Qt Wasm availability must be confirmed independently.
- Zrythm `src/gui/backend/zrythm_application.cpp` initializes JUCE message loop, hardware audio device, plugin scanning, native paths, and FFT/DSP. None are equivalent to WebAudio without source modification.
- ProjectWindow.qml uses native backend C++ types `Session`, `ProjectManager`, `DeviceManager`, etc.; simply uploading QML files cannot create the DAW.
- Native VST3/Kontakt installed on Windows cannot load directly from browser sandbox; no guarantee of parity.

## First executable source-port milestone
Created `scripts/orvia-wasm-build.sh` (commit `83a769a50544b31f628c32b9a8f84acf1d34d380`):
1. Fail fast unless matching Emscripten + Qt 6.11 WebAssembly SDK + native Qt host SDK are present, including CanvasPainter support.
2. Run Emscripten CMake configure **against actual Zrythm root CMakeLists.txt**, no HTML mock or screenshots.
3. Attempt to compile **actual target `zrythm`**.
4. Never claim this implies working browser audio or plugin support.

**Honest current status:** script has been committed but not run against matching Qt 6.11 Wasm toolchain (not installed in current environment). **NO Zrythm WebAssembly artifact, NO functional site.** Compile may require extensive changes or be blocked by Qt CanvasPainter/Wasm dependencies. Do not deploy a fake placeholder.

## Next engineering gates, only with evidence
1. Validate exact Qt 6.11 CanvasPainter Wasm package availability/licensing on a free builder and run script; record full build error instead of inventing success.
2. Isolate native-only JUCE/plugin scanning/device code using a WebAudio/AudioWorklet backend, and a browser-sandbox file persistence path; preserve ProjectWindow.qml and its native models as feasible.
3. Prove first usable browser screen with **real Qt/QML from Zrythm** (not HTML reconstruction); then original track/clip editing, Piano Roll, actual audible playback, saves/loads and mixer in stages.
4. Host real verified Wasm+JS output on temporary Cloudflare Pages and get user acceptance; no new site URL until artifact exists.
5. Leave `master`/Windows branch/SoundCraft fallback/production intact. No paid services, no CMD on user's PC.

**Priority:** web source-port work is now the requested focus; the prior Windows build #39437210753 is unrelated and must not be misrepresented as web progress.
