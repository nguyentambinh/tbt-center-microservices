# ADR 0029: RabbitMQ, Elasticsearch, Eureka trong TBT Center

Ngày: 2026-10-17. Trạng thái: đã áp dụng.

## Bối cảnh
Ba chỗ yếu: bên nhận sự kiện (notification, report) phải hỏi sổ audit định kỳ 5–10 giây một lần; chưa tra được một thao tác đi qua những service nào (chưa có tracing); service gọi nhau bằng địa chỉ cố định, chia tải giữa 2 bản `hr`/`attendance` chỉ có ở Kong.

## Quyết định
- **Đặt ở Hub**, dữ liệu riêng (volume `rabbitmq-data`, `es-data`), cổng ngoài 5673/15673 (RabbitMQ), 9201 (Elasticsearch), 8762 (Eureka).
- **RabbitMQ: hàng đợi sự kiện (Event-Driven, pub/sub)**. Exchange `tbt.events` kiểu topic, khóa `<khu vực>.<service>.<loại sự kiện>`. Audit ở Hub là bên phát duy nhất: ghi sổ xong thì bộ chuyển tiếp (`EventRelay`, bảng `relay_state`) phát lên RabbitMQ, chờ RabbitMQ xác nhận cả lô (publisher confirm) mới dời điểm đánh dấu, tức là giao ít nhất một lần. Tin chỉ có phần nhận diện (mã, loại, khu vực, băm), **không có payload dữ liệu cá nhân**. Bên nhận theo kiểu "báo rồi kéo": `notification.<khu vực>` (khóa `vn.#`) và `report.projector` (khóa `#`) nhận tin thì đọc ngay phần mới từ sổ audit theo điểm đánh dấu của mình. Thứ tự và việc không mất sự kiện vẫn do sổ audit bảo đảm, lượt đọc định kỳ giãn ra 60 giây làm dự phòng.
- **Elasticsearch: gom log request**. Middleware `metrics` của mọi service gửi mỗi request (service, khu vực, bản chạy, đường dẫn, mã trả về, thời gian, người dùng, correlation id) theo lô 2 giây qua `_bulk`; mỗi ngày một index `tbt-requests-*`, tự xóa sau 7 ngày (ILM), hàng đợi tối đa 5.000 dòng khi Elasticsearch chết. Grafana có dashboard "tra cứu request": nhập correlation id để thấy thao tác đi qua những service nào, request lỗi, request chậm.
- **Eureka: sổ đăng ký service (Service Discovery)**. Eureka server ở `deploy/eureka`. Mỗi service Dart tự đăng ký qua REST khi khởi động (IP container, metadata khu vực), nhịp tim 30 giây, tắt container thì gỡ. `InternalClient` hỏi Eureka các bản đang chạy cùng khu vực, chia lượt vòng tròn (client-side load balancing), bản vừa chết chưa kịp gỡ thì gọi lại bằng địa chỉ cố định.

## Hệ quả
- `dart_amqp` 0.3.1 lỗi khi RabbitMQ xác nhận gộp nhiều tin: gửi từng tin, chờ xác nhận; mọi kết nối bọc trong `runZonedGuarded`, lỗi thư viện chỉ làm rớt kết nối rồi nối lại.
- CRS chặn nhầm API quản trị Keycloak: luật 930120 khớp tên trường `credentials`, luật 932130/933135 khớp mô tả vai trò `${role_...}`. Ngoại lệ hẹp ở `deploy/waf/keycloak-exclusions.conf`, request chỉ gửi id, tên vai trò.
- Thông báo và báo cáo cập nhật gần như ngay khi sự kiện vào sổ; số lần hỏi sổ audit giảm khoảng 12 lần.
- Ba thành phần tốn khoảng 1,4 GB RAM (Eureka giới hạn heap 160 MB, Elasticsearch 384 MB).
- Một điểm hỏng mới ở Hub cho mỗi thành phần, nhưng đều có đường lùi: RabbitMQ chết thì bên nhận vẫn đọc định kỳ; Elasticsearch chết thì log xếp hàng rồi bỏ bớt, service không bị ảnh hưởng; Eureka chết thì gọi bằng địa chỉ cố định.
- Elasticsearch và Eureka đang tắt xác thực, chỉ mở trong máy dev; triển khai thật phải bật xpack.security và đặt sau mạng nội bộ.

Thành phần liên quan: A3 Service Registry, A6 Log tập trung, message broker.

Yêu cầu liên quan: R45, R50 (giám sát, bảo trì từng thành phần), R52, R53 (lưu vết, truy xuất nguồn gốc).
