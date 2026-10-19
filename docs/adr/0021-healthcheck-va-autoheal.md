# ADR 0021: Healthcheck cho mọi service và autoheal

Ngày: 2026-10-16. Trạng thái: đã áp dụng.

## Bối cảnh
`restart: unless-stopped` chỉ khởi động lại container đã chết. Container treo (còn chạy, không trả lời) thì Docker Compose không tự xử lý. Image service build từ `scratch` nên không có curl để làm healthcheck.

## Quyết định
- Chương trình `deploy/docker/healthcheck.dart` (gọi `GET /` của chính service) biên dịch thành `/app/healthcheck` trong mọi image; Dockerfile khai `HEALTHCHECK` 15 giây, 3 lần lỗi thì unhealthy.
- Container `willfarrell/autoheal` ở Hub đọc Docker socket, khởi động lại container unhealthy. Một bản cho cả máy.
- Prometheus nhận biết service vừa khởi động lại qua số liệu `tbt_process_start_time_seconds`, luật `ServiceRestarted` gửi email (ADR 0024).

## Hệ quả
- Đã thử: đóng băng server `bank_mock` VN, khoảng 75 giây sau tự hoạt động lại, không ai can thiệp.
- autoheal cần quyền Docker socket (quyền rất lớn); chấp nhận ở máy dev. Lên Kubernetes thì thay bằng liveness probe.

Yêu cầu liên quan: R45, R50.
