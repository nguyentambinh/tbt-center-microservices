# ADR 0004: Nhật ký bất biến bằng chuỗi băm trong PostgreSQL

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Kiểm toán cần nhật ký chỉ ghi thêm. Cần chứng minh được dữ liệu cung cấp cho kiểm toán không bị sửa.

## Quyết định
- Service `audit` ở Hub lưu sự kiện vào bảng `events`. Trigger trong database chặn mọi lệnh `update`, `delete`.
- Mỗi dòng lưu `prev_hash` và `hash = SHA-256(prev_hash | khu vực | service | id outbox | loại sự kiện | nội dung)`. Băm tính ngay trong Postgres để lúc ghi và lúc kiểm tra dùng cùng công thức.
- Ghi theo lô dưới khóa `pg_advisory_xact_lock` để hai lô song song không cùng nối vào một `prev_hash`.
- `GET /verify` tính lại toàn bộ chuỗi, trả dòng đầu tiên bị sửa nếu có.

## Hệ quả
- Sửa một dòng cũ (kể cả bằng quyền database) thì từ dòng đó trở đi chuỗi không khớp.
- Sự kiện gửi lên Hub chỉ mang thông tin cần cho kiểm toán và báo cáo; email, số điện thoại của ứng viên không rời khu vực.

Yêu cầu liên quan: R42, R52, R53, R89.
