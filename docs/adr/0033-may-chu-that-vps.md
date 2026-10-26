# ADR 0033: Chạy online trên một máy chủ thật (VPS)

Ngày: 2026-10-25. Trạng thái: đã áp dụng.

## Bối cảnh
Hệ thống cần chạy được trên Internet, không chỉ trên máy dev qua `adb reverse`. Có một VPS Ubuntu 24.04 (8 nhân, 16 GB RAM, 100 GB NVMe, 100 Mbps), chưa có tên miền riêng. App bắt buộc Keycloak dùng HTTPS khi không chạy `localhost`.

## Quyết định
- Trên VPS chạy Hub (Docker Compose), các khu vực VN, US, BR, ZA, AU (Docker Compose) và khu vực DE (k3s cài thẳng trên máy, cùng manifest `deploy/k8s/de`, thêm overlay sinh ra trên máy chủ).
- **Caddy** (`deploy/vps/compose.edge.yml`) là cổng vào duy nhất, tự xin chứng chỉ Let's Encrypt. Tên miền dùng `sslip.io`: `<tên>.<IP nối bằng gạch>.sslip.io` tự trỏ về IP máy chủ, nên có HTTPS mà không cần mua tên miền. Mỗi thành phần một tên: `auth` (Keycloak qua WAF), `geo`, `vn`, `de`, `us`, `br`, `za`, `au` (Kong từng khu vực qua WAF), `s3-<khu vực>` (Garage, URL ký sẵn), `grafana`, `privacy`.
- Địa chỉ công khai là biến: `KC_HOSTNAME`, `JWT_ISSUER`, `S3_PUBLIC_ENDPOINT` trong compose (mặc định vẫn là `localhost`), `KONG_URL`, `KEYCLOAK_URL`, `GEO_URL` khi build app (`--dart-define`). Giá trị của máy chủ nằm ở `deploy/vps/vps.env` (không lên git).
- `kong.yml` trên máy chủ sinh lại bằng `sync-kong-jwt.sh` với issuer công khai, nên Kong chỉ nhận token do Keycloak trên máy chủ cấp.
- **Tường lửa** (`deploy/vps/firewall.sh`): ufw chỉ mở 22, 80, 443. Cổng Docker mở ra đi vòng qua ufw nên chặn thêm ở chuỗi `DOCKER-USER` (kết nối mới từ card mạng ngoài bị bỏ); NodePort của k3s chặn ở `mangle PREROUTING` trước khi kube-proxy đổi đích. Container và pod trong máy vẫn gọi nhau. Postgres, Prometheus, RabbitMQ, Doris, Elasticsearch không vào được từ Internet.
- Pod của k3s gọi Hub qua `host.docker.internal`, trỏ về địa chỉ docker0 bằng ConfigMap `coredns-custom`. Grafana đọc Prometheus DE qua Caddy ở cổng 9190 của docker0.
- Dữ liệu chép từ máy dev: Postgres Hub (Keycloak, audit, kho tri thức), Postgres và Garage của cả 6 khu vực; replica tự sao lại từ primary; Doris tự chiếu lại từ sổ audit.
- Khóa: chỉ chép khóa service cần (`deploy/vps/push.sh`). Khóa Anthropic, mật khẩu ứng dụng Gmail, khóa payOS không tự chép: AI dùng Gemini, chi lương qua ngân hàng giả lập, Alertmanager chưa gửi email.

## Hệ quả
- Đã kiểm: Keycloak cấp token với issuer HTTPS; qua `https://vn.…` và `https://de.…` không token 401, có token 200, sai vai trò 403; Doris chiếu 486 sự kiện, báo cáo tập đoàn trả số liệu; replica DE `streaming`; Prometheus DE 12/12 target; quét từ ngoài: mọi cổng nội bộ và NodePort đều bị chặn.
- E2E giao diện thật trên máy ảo, app build trỏ về VPS, không dùng `adb reverse`: 5/5 vai trò (VN, DE) qua, mỗi màn 350–1.050 ms. Đăng nhập thật qua trang Keycloak HTTPS (PKCE) vào được màn chính.
- RAM máy chủ: Hub khoảng 5,2 GB, mỗi khu vực Compose khoảng 0,66 GB, DE trên k3s khoảng 0,7 GB pod; đủ 6 khu vực khoảng 11,5/15,9 GB (119 container, 20 pod).
- `sslip.io` là dịch vụ bên ngoài: nếu nó ngừng thì phải đổi sang tên miền riêng (chỉ sửa `vps.env` rồi chạy lại Caddy, build lại app).
- Grafana, trang quản trị Keycloak, client thử `tbt-dev-cli` (cấp token bằng mật khẩu) đang mở ra Internet có đăng nhập; môi trường thật nên tắt client thử và giới hạn trang quản trị theo IP.

Lệnh: từ máy dev `bash deploy/vps/push.sh root@<máy chủ> all`; trên máy chủ `bash deploy/vps/up.sh hub|region <kv>|regions|de|edge|all|status`.

Yêu cầu liên quan: R14, R23, R45, R46, R47, R48, R50.
