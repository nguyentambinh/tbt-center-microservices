# ADR 0005: Circuit Breaker tự viết trong packages/common

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Resilience4j chỉ có cho Java. Backend viết bằng Dart nên cần một Circuit Breaker riêng cho các lời gọi ra ngoài: ngân hàng, đối tác hạ tầng, Claude API.

## Quyết định
`CircuitBreaker` trong `packages/common` có 3 trạng thái:
- **closed**: gọi bình thường, đếm lỗi liên tiếp;
- **open**: đủ ngưỡng lỗi (mặc định 3) thì ngắt, từ chối ngay mọi lời gọi trong thời gian ngắt;
- **half-open**: hết thời gian ngắt thì cho một lời gọi thử; thành công thì đóng mạch, lỗi thì ngắt tiếp.

Người dùng truyền `isFailure` để chỉ lỗi phía dịch vụ (quá tải, lỗi máy chủ, mất kết nối) mới làm ngắt mạch; lỗi do dữ liệu đầu vào không tính.

## Hệ quả
- Đang dùng cho lời gọi Claude API trong `recruitment` (ngắt 2 phút). Trạng thái mạch hiện ở `GET /` của service để giám sát.
- Sẽ dùng lại cho `integration` khi gọi ngân hàng (R72).

Yêu cầu liên quan: R49, R70, R72.
