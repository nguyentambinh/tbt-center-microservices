# ADR 0010: CQRS: mô hình đọc ở Doris, nạp từ sổ sự kiện

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Lãnh đạo cần báo cáo hợp nhất toàn tập đoàn (R01, R02, R60), nhưng dữ liệu chi tiết nằm rải ở database từng khu vực và không được tập trung về một chỗ.

## Quyết định
- **Phía ghi**: các service ở khu vực, ghi sự kiện qua Outbox.
- **Luồng sự kiện**: `sync_worker` đưa sự kiện về sổ `audit` ở Hub.
- **Phía đọc**: Apache Doris ở Hub, các bảng `payroll_cost`, `leave_requests`, `candidates` dạng UNIQUE KEY.
- **Bộ chiếu** trong service `report` đọc sự kiện mới của `audit` mỗi 10 giây, đổi thành dòng của bảng đọc (hàm thuần `projectEvent`), nạp bằng Stream Load. Mỗi lô có nhãn riêng nên nạp lại không ghi trùng; mốc đã chiếu tới đâu lưu ở `projection_checkpoint`.
- `report` đọc Doris bằng SQL API qua HTTP của FE, không cần thư viện MySQL. App gọi `/report/overview` qua Kong của khu vực, chỉ executive, admin, finance xem được.
- Sự kiện chỉ mang số tổng hợp (ví dụ tổng lương một đợt quy USD), không mang lương từng người hay thông tin liên hệ.

## Hệ quả
- Báo cáo đi sau dữ liệu thật vài giây (nhất quán cuối cùng). API trả kèm `projectedUntilEvent` để app biết số liệu mới tới đâu.
- Đã thử: lương VN (VND) và DE (EUR) cộng thành tổng USD toàn tập đoàn; sau khi bật đủ 6 khu vực, tổng lương tháng 10/2026 là 527.506,31 USD.
- Dựng lại (rebuild): `POST /report/rebuild` (admin) đưa mốc về 0, bộ chiếu phát lại toàn bộ sổ audit. Dùng khi thêm bảng đọc mới (ví dụ `work_hours` cho điều kiện làm việc). Nhãn Stream Load mang mã lần chạy để nạp lại được; bảng UNIQUE KEY nên nạp lại không sinh dòng trùng.

Yêu cầu liên quan: R01, R02, R03, R17, R22, R60, R62.
