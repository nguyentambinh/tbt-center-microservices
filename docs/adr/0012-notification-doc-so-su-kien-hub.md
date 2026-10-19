# ADR 0012: notification đọc dòng sự kiện ở sổ audit của Hub

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Thông báo Service đặt ở khu vực, cần nhận sự kiện (đơn nghỉ được duyệt, phát lương, hồ sơ ứng viên đổi trạng thái) rồi gửi email, thông báo đẩy (R18, R97). Dự án không có Kafka (ADR 0002): sự kiện đi từ Outbox các service qua `sync_worker` lên sổ `audit` ở Hub. Cho notification đọc thẳng bảng outbox của service khác thì phá Database-per-service; cho `sync_worker` gửi thêm tới notification thì notification hỏng sẽ chặn luôn việc đồng bộ lên Hub.

## Quyết định
- notification ở mỗi khu vực là một **consumer** của sổ sự kiện ở Hub: hỏi `GET /events?region=<khu vực>&after=<mốc>` (kèm `X-Sync-Token`), mỗi lô lưu thông báo và dời mốc (`consumer_checkpoint`) **trong cùng một giao dịch**.
- **Idempotent consumer**: khóa `unique (event_id, recipient)`, đọc lại cùng sự kiện không sinh thông báo trùng. Sự kiện cũ không có `event_id` thì bỏ qua.
- Luật "sự kiện nào báo cho ai" là hàm thuần `notificationsFor`. Người nhận là `employee:<mã>`, `candidate:<mã hồ sơ>` hoặc `role:<vai trò>`; đã đọc lưu theo từng người (`notification_reads`).
- Thông báo lưu **loại + tham số**, không lưu câu: app ghép câu theo ngôn ngữ đang chọn (vi/en/de/pt).
- Sự kiện lên Hub không mang thông tin tài khoản ứng viên. notification hỏi recruitment qua `/internal/candidate-of?sub=` để biết tài khoản nào ứng với hồ sơ nào.
- Thông báo đẩy qua `PushSender`. Chưa có Firebase project nên đang dùng `LogPushSender` (chỉ ghi log); app hỏi lại hộp thư mỗi 30 giây. Có tài khoản dịch vụ FCM thì thay bằng bản gửi FCM, không phải sửa chỗ khác. Máy đã lưu mã thiết bị qua `POST /devices`.

## Hệ quả
- notification hỏng hay chậm không ảnh hưởng đồng bộ lên Hub và nghiệp vụ chính (R49).
- Hub mất kết nối thì khu vực tạm không có thông báo mới; nghiệp vụ vẫn chạy, nối lại thì đọc tiếp từ mốc cũ.
- Thông báo đi sau sự việc khoảng 5–30 giây (sync_worker 5 giây, notification 5 giây, app 30 giây).
- Dữ liệu `notification_db` dựng lại được từ sổ ở Hub: xóa bảng và mốc thì nó đọc lại từ đầu.

Yêu cầu liên quan: R18, R48, R49, R97, R102.
