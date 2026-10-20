# ORVIA Desktop — hồ sơ nền tảng native

> **Lưu ý:** Đây là tài liệu kỹ thuật dành riêng cho nhánh phát triển ORVIA của fork Zrythm, KHÔNG phải bản build ORVIA, không được quảng bá rằng phần mềm đã chạy.

- Dự án: **ORVIA** thuộc **LUNOR MUSIC**
- Đích: DAW chạy native **Windows 10/11 x64** (giai đoạn đầu).
- Fork: https://github.com/Gamevalentine/zrythm
- Upstream: https://github.com/zrythm/zrythm
- Commit nền đã xác minh (fork `master`): `4c2d47143da71ab8cb08141890e7b36fe7974312` (2026-10-13).
- Nhánh làm việc: `feature/orvia-desktop-foundation`.
- Hệ thống theo dõi riêng: https://feature-orvia-zrythm-desktop.orvia-daw-preview.pages.dev (không phải DAW web).
- Nhật ký kỹ thuật chung LUNOR MUSIC trên Google Drive phải được đọc trước khi sửa tiếp.

## Quy tắc bất biến

1. **Giữ `master` của bản fork nguyên trạng** làm baseline so sánh và dễ cập nhật upstream. Chưa tự merge hay phát hành.
2. **Không sửa/xóa DSP, audio engine, project format, MIDI, plugin host**, trước khi xây dựng và kiểm thử baseline Windows.
3. **Không chạy GitHub Actions** khi chưa được chủ dự án duyệt (hạn mức/chi phí); không bắt người dùng dùng CMD hoặc tải toolchain về C:. Không dùng dịch vụ trả phí hay TinyFish.
4. Không tạo bản demo web giả. Trang theo dõi chỉ có commit, tiến độ, lỗi, ảnh/video/log chạy trên native desktop thực tế.
5. Đổi tên sản phẩm khi đến mốc branding: **ORVIA**, tuyệt đối không dùng tên/logo Zrythm làm nhãn của bản phần mềm chỉnh sửa khi phân phối. **Giữ** thông báo bản quyền, ghi công nguồn, giấy phép AGPL-3.0-or-later và giấy phép từng phụ thuộc. Không được tự đổi license sang MIT/Apache.
6. Chỉ đóng gói bản Windows cho người dùng kiểm thử sau khi baseline thực chạy và các kiểm thử quan trọng đạt.

## Những gì đã xác minh từ source Zrythm

| Nội dung | Kết quả kiểm tra |
|---|---|
| Nền công nghệ | C++23, Qt/QML, JUCE 8, CMake + Conan/CPM |
| Điều kiện build Windows upstream | Visual Studio 2022 (Desktop C++), Qt cùng compiler và config |
| Qt yêu cầu | `find_package(Qt6 6.11 ... REQUIRED)` trong `CMakeLists.txt` — nhiều module Qt bao gồm `CanvasPainter` |
| Features upstream hiện liệt kê | Arranger/timeline, audio+MIDI record, piano roll+velocity, automation, mixer, plugin browser, VST3/CLAP |
| Chưa đầy đủ ở v2 | Theo README, stem export, project backup, một số MIDI và audio workflows từ v1 chưa port |
| License chính | `LICENSES/LicenseRef-ZrythmLicense.txt`: GNU AGPL version 3-or-later với điều khoản bổ sung |
| Trademark | `TRADEMARKS.md`: cấm dùng logo/tên Zrythm làm branding cho bản sửa đổi khi không được phép |
| Phụ thuộc | Nhiều thư viện sử dụng giấy phép riêng, cần kiểm tra `REUSE.toml`/SBOM trước phân phối |

## Tiến độ theo bằng chứng

- [x] Người dùng tạo **fork thật** `Gamevalentine/zrythm` và cấp quyền GitHub.
- [x] Xác nhận fork `master` trỏ commit nền `4c2d471...`.
- [x] Tạo **nhánh ORVIA riêng**, giữ master.
- [x] Đọc `README.md`, `CMakeLists.txt`, `AGENTS.md`, `COPYING`, `TRADEMARKS.md` và giấy phép Zrythm.
- [ ] Kiểm toán đầy đủ license từng dependency / tài sản cần đóng gói.
- [ ] **Build ứng dụng Zrythm Windows nguyên bản** từ fork tại commit nền (không tự đổi thương hiệu trước).
- [ ] Test native: mở app, project, Play/Stop, MIDI clip, piano roll, velocity, mixer, import/export, VST3.
- [ ] Thu thập Windows screenshot/video/log **thật** và đưa lên trang theo dõi.
- [ ] Bắt đầu thay text/icon/branding thành ORVIA và test không còn Zrythm trademark ở bản phát hành sửa đổi.
- [ ] Đóng gói Windows build QA, cung cấp hash và link tải để người dùng nghiệm thu.

## Trình tự tiếp theo — Windows baseline

1. Chọn **môi trường build Windows riêng**, không dùng máy cá nhân của người dùng và không yêu cầu CMD. GitHub Actions hiện **chưa được duyệt sử dụng**; không chủ động bật.
2. Đối chiếu toolchain Visual Studio 2022 + Qt 6.11 tương thích, Conan nếu cần; kiểm tra quyền truy cập thư viện và thời gian build.
3. Xây dựng **Zrythm baseline chưa chỉnh sửa**; chỉ báo pass nếu có log compile, .exe thực tế và chạy được.
4. Sau baseline, sửa branding theo từng cụm độc lập và build/test lại. Khi app chạy mới chụp hình/quay video cho website tạm.

### Nguồn

- [Zrythm README](https://github.com/zrythm/zrythm/blob/master/README.md)
- [Upstream AI agent guide](https://github.com/zrythm/zrythm/blob/master/AGENTS.md)
- [Zrythm trademark policy](https://github.com/zrythm/zrythm/blob/master/TRADEMARKS.md)
- [Main license declaration](https://github.com/zrythm/zrythm/blob/master/COPYING)

## Nhật ký thực thi
**2026-10-20:** Kiểm tra trực tiếp fork của chủ dự án, xác nhận `master=4c2d471...`. Khởi tạo nhánh ORVIA và tài liệu này, chưa đổi code upstream. **Chưa build hoặc kiểm thử Windows; chưa có installer.** Nhiệm vụ tiếp: chọn builder không tốn phí và có quyền trước khi chạy build.


## Lần build Windows baseline #1 (20/10/2026 — đang chạy)

- **Đã đọc nhật ký LUNOR MUSIC / ORVIA trước thao tác**, kiểm tra AGENTS.md, README.md, CMakeLists.txt, Conan profiles + conan.lock, .gitlab-ci.yml và các điều kiện thực thi Windows.
- Các thiết bị Remote Desktop không online, connector đã hết lượt; không dùng máy người dùng, không yêu cầu CMD hay ghi vào C:.
- Giấy phép GitHub Actions public standard runners: miễn phí không giới hạn phút cho repo công khai (theo GitHub Docs), không dùng larger/paid runner.
- Tệp `.github/workflows/orvia-windows-baseline.yml` được tạo **chỉ trên nhánh `feature/orvia-desktop-foundation`** (commit `dc413ca66a960998d9ba0f31552b4d3b9eaf926a`) với push filter chỉ chính tệp workflow và tùy chọn workflow_dispatch. Runner `windows-2025-vs2026` dùng toolchain MSVC 19.5 như upstream `conan/profiles/_msvc`; checkout full submodule; Python pinned requirements, Conan recipes local và lockfile, build CMake + exe nếu đủ môi trường. Timeout tối đa 180 phút; chưa đóng gói phát hành.
- **Run thật:** https://github.com/Gamevalentine/zrythm/actions/runs/39437210753 (job ID `118677283684`). Phần **checkout submodule, preflight MSVC, Python build tools** đã hoàn thành SUCCESS. Phần Conan dependency đang IN_PROGRESS tại thời điểm cập nhật; native CMake compile chưa bắt đầu. **CHƯA có .exe, chưa xác nhận runtime/âm thanh/VST3**. Cần theo dõi kết quả lần build, sửa build workflow theo log nếu thất bại, rồi chỉ dùng ảnh/video từ native binary chạy thật.
- **Bảo toàn:** master `4c2d47143da71ab8cb08141890e7b36fe7974312` không thay đổi; mã Zrythm/audio engine/GUI chưa sửa; chỉ thêm tài liệu + workflow build.
