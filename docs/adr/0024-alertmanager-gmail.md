# ADR 0024: Alertmanager gửi cảnh báo về Gmail

Ngày: 2026-10-16. Trạng thái: đã áp dụng.

## Bối cảnh
Prometheus đã có luật cảnh báo (ADR 0013) nhưng chỉ xem được trên trang Alerts. R70 cần cảnh báo khi dịch vụ đối tác hoặc hạ tầng gặp sự cố; người phụ trách phải biết mà không cần mở Prometheus.

## Quyết định
- Một Alertmanager ở Hub (cổng 9093); Prometheus Hub và 6 khu vực cùng đẩy cảnh báo về.
- Gửi qua Gmail SMTP bằng mật khẩu ứng dụng của Bình, đọc từ file `deploy/secrets/gmail-app-password.txt` (`smtp_auth_password_file`), không nằm trong cấu hình.
- Email HTML theo mẫu riêng `deploy/alertmanager/email.tmpl`; gom theo tên cảnh báo và khu vực; gửi cả khi hồi phục; service đã chết thì không gửi thêm cảnh báo phụ của nó.
- Thêm luật `ServiceRestarted` để biết khi Docker hoặc autoheal khởi động lại service.

## Hệ quả
- Đã thử: dừng `bank_mock` VN, khoảng 2 phút sau có email ServiceDown, bật lại có email đã hồi phục; 9 email gửi thành công, 0 lỗi.
- Triển khai bản mới (tạo lại nhiều container) sẽ sinh email ServiceRestarted theo từng khu vực.
- Mã ứng dụng Gmail đã xuất hiện trong đoạn chat với trợ lý AI; nên thu hồi và tạo mã mới sau khi demo.

Yêu cầu liên quan: R45, R70.
