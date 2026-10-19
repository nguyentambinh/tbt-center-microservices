# ADR 0002: Outbox + sync_worker thay cho Kafka, Debezium, MirrorMaker 2

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Phương án đầy đủ dùng Kafka làm broker, Debezium đọc thay đổi database, MirrorMaker 2 đẩy sự kiện từ khu vực về trụ sở. Máy dev chỉ chạy được Hub và 2–3 khu vực; dựng thêm cụm Kafka cho mỗi khu vực vượt quá tài nguyên.

## Quyết định
- Mỗi service ghi sự kiện vào bảng `outbox` **trong cùng giao dịch** với dữ liệu nghiệp vụ (`addOutboxEvent`).
- Mỗi khu vực chạy một `sync_worker` đọc các bảng outbox, gửi lô sự kiện lên service `audit` ở Hub, đánh dấu đã gửi. Hub lỗi thì chờ lâu dần (5 → 60 giây) rồi gửi lại.
- Mỗi sự kiện có `event_id` (UUID). Hub chống trùng theo `event_id`, nên gửi lại bao nhiêu lần cũng chỉ ghi một lần.
- Interface giữ đơn giản để sau này thay `sync_worker` bằng Kafka mà không sửa các service.

## Hệ quả
- Không mất sự kiện: dữ liệu và sự kiện cùng thành công hoặc cùng thất bại.
- Độ trễ đồng bộ vài giây thay vì gần thời gian thực.
- Ban đầu Hub chống trùng theo id tự tăng của outbox; nạp lại database làm id đánh lại từ 1 và Hub âm thầm bỏ sự kiện mới. Đã đổi sang `event_id` (migration `*_outbox_event_id.sql`).

Yêu cầu liên quan: R10, R16, R48, R93.
