# ADR 0013: Giám sát bằng Prometheus mỗi khu vực, Grafana ở Hub

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Cần Prometheus, Grafana, Alertmanager để giám sát trạng thái thành phần (R45), mức dùng tài nguyên (R69) và cảnh báo khi dịch vụ đối tác gặp sự cố (R70). Service viết bằng Dart nên không có sẵn thư viện client Prometheus chính thức. Image service build từ `scratch` nên không có công cụ dòng lệnh bên trong.

## Quyết định
- `tbt_common` có middleware `metrics('<tên service>')` đặt ngoài cùng ở mọi service dart_frog. Nó đếm request theo đoạn đầu đường dẫn và mã trả về, đo thời gian xử lý (histogram), báo trạng thái các Circuit Breaker (`tbt_circuit_state`: 0 đóng, 1 thử lại, 2 đang ngắt), và mở `GET /metrics` theo định dạng text của Prometheus.
- Chỉ lấy đoạn đầu đường dẫn làm nhãn (`/employees`, không lấy `/employees/AN001`) để số chuỗi số liệu không tăng theo id.
- Mỗi khu vực một Prometheus (cổng `PROM_PORT`: VN 9090, DE 9190…) đọc service trong mạng nội bộ của khu vực, nhãn `region` lấy từ biến môi trường. Hub có Prometheus riêng (9099) cho audit, report, Doris.
- Grafana ở Hub (cổng 3000, tài khoản dev chung) có sẵn nguồn dữ liệu của Hub và 6 khu vực, cùng dashboard "TBT Center: tình trạng hệ thống" có ô chọn khu vực.
- Luật cảnh báo trong `deploy/prometheus/alerts.yml`: `ServiceDown`, `PartnerCircuitOpen` (R70), `HighServerErrorRate`, `SlowRequests`.
- `/metrics` không được lộ ra ngoài: Kong có route regex `~/[^/]+/metrics$` trả 404.

## Hệ quả
- Đã thử: Prometheus VN, DE đọc được 10/10 service, Hub đọc được 3/3. Tắt `bank_mock` VN hơn 1 phút thì `ServiceDown` bật. Gọi `/hr/metrics` qua Kong có token vẫn bị 404.
- Chưa có Alertmanager (chưa gửi cảnh báo qua email hay chat), chưa có OpenTelemetry tracing. Để lần vết một request qua nhiều service, hiện dùng `X-Correlation-Id` trong log.
- Số liệu nằm trong bộ nhớ service: khởi động lại thì đếm lại từ 0. Prometheus tự xử lý trường hợp này khi tính `rate`.
- `sync_worker` không phải service HTTP nên chưa có số liệu; muốn biết nó còn chạy thì xem log hoặc xem sự kiện ở Hub có tăng không.

Yêu cầu liên quan: R45, R49, R50, R69, R70.
