# ADR 0008: App chạy online, có cache cho dữ liệu đọc

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Room chỉ dùng được cho app Android native. Chạy online hoàn toàn thì người dùng ở công trường mất mạng là không xem được gì.

## Quyết định
- Mọi lời gọi mạng đi qua một `ApiClient` (Dio). Kết quả GET gần nhất được lưu ra file; mất mạng thì trả dữ liệu đã lưu và ghi chú "đang hiển thị dữ liệu đã lưu".
- Thao tác ghi bắt buộc có mạng; mất mạng thì báo lỗi, giữ nguyên dữ liệu người dùng đã nhập. Mỗi thao tác ghi có `Idempotency-Key` để gửi lại không bị ghi trùng.
- Thanh báo trên cùng màn hình cho biết mất mạng, không tới được máy chủ, mạng chậm, hoặc đã kết nối lại; có nút kết nối lại và tự thử lại sau 2–30 giây.
- Đăng xuất thì xóa cache để người sau dùng máy không xem được dữ liệu cũ.

## Hệ quả
Không cần SQLite cục bộ và cơ chế đồng bộ hai chiều phức tạp, mà người dùng vẫn xem được dữ liệu khi mạng chập chờn.

Yêu cầu liên quan: R47, R49.
