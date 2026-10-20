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


## Giai đoạn 1 — kiểm thử thật ngày 20/10/2026

**Trước thao tác:** Đã đọc nhật ký LUNOR MUSIC Google Drive, nhật ký WebAssembly của ORVIA này, `AGENTS.md`, `CMakeLists.txt`, `package-lock.cmake`, và code ProjectWindow/QML. Đã kiểm tra tài liệu Qt 6.11/WebAssembly chính thống.

**Phát hiện về Qt:** Qt 6.11.1 có gói `wasm_singlethread` và add-on `qtcanvaspainter.wasm_singlethread` thật, được phân phối qua Qt online installer. Vì vậy không được tự giả định CanvasPainter WASM hoàn toàn không tồn tại. Gói Qt host + Qt Wasm + Emscripten 4.0.7 đã được kiểm chứng cài thành công trên GitHub runner Linux công khai miễn phí.

**Mã đã thay đổi, nhánh Web riêng:**
- `scripts/orvia-wasm-build.sh`: preflight `emcc/emcmake/em++`, Qt host 6.11.1 + Qt Wasm 6.11.1 và CanvasPainter; gọi `emcmake cmake` trực tiếp lên **source Zrythm gốc**, không có HTML/mock.
- `.github/workflows/orvia-qt-wasm-probe.yml`: một job miễn phí `ubuntu-24.04`, timeout 45 phút, cài Qt SDK WebAssembly + Qt host và Emsdk 4.0.7, chạy script trên source thật. Trigger chỉ khi sửa workflow/CMake/script trên nhánh Web. Không chạm `master`, không dùng VM từ xa hoặc dịch vụ có phí.
- `CMakeLists.txt` thêm điều kiện `if(EMSCRIPTEN)` quanh 2 thư viện JSON, lấy từ **existing pinned CPM definitions** để không bắt buộc dùng Conan native. Phần Windows/Linux/macOS giữ nguyên.

**GitHub Run #1:** https://github.com/Gamevalentine/zrythm/actions/runs/39450074122 — `completed / failure`. **PASS**: checkout, Qt host CanvasPainter, Qt WebAssembly CanvasPainter, Emsdk 4.0.7; CMake nhận emcc/em++, Zrythm version v2.0.0-alpha.6 và cấu hình source tới dòng `CMakeLists.txt:817`. **FAIL**: `find_package(nlohmann_json REQUIRED)` vì project dùng Conan cho desktop, Conan dependencies chưa được cấu hình cho Emscripten. Đây là blocker đầu tiên có log thật, không phải kết luận rằng Qt không chạy được.

**Cách xử lý Run #1:** `CMakeLists.txt` commit `aa56be9148858e04ac5e8752744443382528604c`: khi `EMSCRIPTEN` dùng `CPMGetPackage(nlohmann_json)` và `CPMGetPackage(nlohmann_json_schema_validator)` theo `package-lock.cmake` có sẵn; các nền tảng native tiếp tục `find_package()`. Commit workflow trigger `92a36a9b2b77d39e43c9ddc0f87aee6babc5ca80` để chạy lại thực tế.

**GitHub Run #2:** https://github.com/Gamevalentine/zrythm/actions/runs/39450673455. Đã PASS Qt host/Wasm/CanvasPainter + Emsdk; ở thời điểm ghi CMake/compile đang in progress. Phải đọc kết quả đầy đủ để xác định có vượt được hai thư viện JSON hay chưa.

**Chưa có:** bundle .wasm của ứng dụng Zrythm, browser GUI chạy thật, âm thanh/MIDI đã QA, hoặc URL Cloudflare tương tác. Không deploy ảnh chụp và không phát hành bản giả. Việc tiếp theo chỉ sửa dựa trên lỗi thực từ lần #2.



### Follow-up source attempts #2 and #3, new blocker (#4 pending)

**Run #2** https://github.com/Gamevalentine/zrythm/actions/runs/39450673455 — completed/failure. `nlohmann_json` and `nlohmann_json_schema_validator` PASS through CPM; CMake continued CLAP/VST3/JUCE, then stopped in `ext/CMakeLists.txt:91`: `Could NOT find Freetype` (plus Fontconfig). Root cause: Emscripten sets `UNIX`, and Zrythm's `OS_GNU` heuristic incorrectly enabled native Linux-only JUCE dependencies.

**Fix** commit `e02731cc51f2f94e40a21e83c7690dce712cc632`: platform gate `if(UNIX AND NOT APPLE AND NOT EMSCRIPTEN)`, and browser branch does not use `xdg-open`. Native Windows/Linux behavior stays unchanged.

**Run #3** https://github.com/Gamevalentine/zrythm/actions/runs/39451311182 — completed/failure. Passes JSON/CLAP/VST3/JUCE configuration and native Freetype gate, then fails at `CMakeLists.txt:844 find_package(SndFile REQUIRED)`. No WebAssembly-compatible libsndfile target supplied by desktop Conan flow.

**Fix** commit `20c41051f83071a2c2e9ec4ede57065878aee178`: `if(EMSCRIPTEN) CPMGetPackage(SndFile)` using the repository's existing pinned source declaration, else native `find_package(SndFile)`; avoids cross-linking host Linux .so.

**Run #4** https://github.com/Gamevalentine/zrythm/actions/runs/39452016659 queued at time of entry. Anticipated major blocker: `find_package(lilv REQUIRED)` and `src/plugins/CMakeLists.txt` unconditionally compile LV2 native plugin sources and link `lilv::lilv`; `src/gui/backend/zrythm_application.cpp` initializes JUCE desktop audio devices, scanning and native plugin managers. These need a real browser-adapter design rather than fake stubbed UI; no architecture port has been claimed.

**Status remains NOT BUILT:** no .wasm bundle, no browser DAW, no screenshots claimed as DAW. All source changes in separate WebAssembly branch; no production/master edits.


## GĐ1 — lần kiểm thử #4 và kết luận rào cản kiến trúc (20/10/2026)

**Run #4 — verified:** https://github.com/Gamevalentine/zrythm/actions/runs/39452016659 (completed / failure). PASS all Qt 6.11.1 host+Wasm CanvasPainter and Emscripten 4.0.7 steps. Source CMake PASS previously missing JSON, desktop OS detection, and **SndFile**: log says `CPM: Adding package SndFile@1.2.2` and libsndfile configure checks run on Emscripten. CMake now fails `CMakeLists.txt:856 find_package(lilv REQUIRED)`, missing `lilvConfig.cmake`.

### Why stopping at lilv rather than cheating with a dummy target
The problem is structural, not just an absent CMake package. The original `src/plugins/CMakeLists.txt` unconditionally compiles `lv2_discovery.cpp`, `lv2_plugin.cpp`, `lv2_plugin_format.cpp`, `lv2_world.cpp` and VST3 host native files, and links `lilv::lilv` PUBLIC (and copies LV2 native spec bundle files). `src/gui/backend/zrythm_application.cpp` constructs hardware audio via JUCE devices, scans host plugins and requires LV2 specification bundles on startup. Browser execution cannot use native installed LV2/VST3/Kontakt binaries.

**No fake workaround:** Do not create an empty `lilv::lilv` interface library or skip `find_package` merely to get a green CMake status. That would leave the real application unable to link or execute. Do not invent a standalone HTML UI. The needed next engineering work is an actual browser backend while retaining the existing Zrythm Qt/QML views and business models:
1. A WebAssembly-only plugin/runtime abstraction separating native LV2/VST3 module scanning, loading, and host UI from the program's core project/track data structures. Native branches must retain the real plugin host and original QA.
2. A browser-compatible JUCE/Qt event+audio backend (AudioWorklet output), browser-local file persistence instead of native filesystem paths, and imports/exports bridged securely.
3. Reattempt CMake and actual `zrythm` target compilation until a genuine Wasm binary exists, then verify browser UI + audio; never publish an image/progress page instead.

### Stage 1 status
- Verified: WebAssembly SDK including Qt CanvasPainter is real and installable; Zrythm CMake recognizes Emscripten, and three *build configuration* blockers have targeted fixes on web branch only. All 4 CI attempts are traceable in GitHub Actions.
- Not verified: `lilv`/VST3/JUCE browser host support, actual Zrythm GUI .wasm build, loading in Chrome, interactive MIDI/audio, or Cloudflare web deployment. **GIAI ĐOẠN 1 CHƯA HOÀN THÀNH.**
- Master, production, SoundCraft fallback and native Windows branch remain untouched.
