# TBT Center đa quốc gia

Hệ thống quản lý nhân sự và tài chính, Nhóm 16.

## Chuẩn bị
```
flutter pub get        # chạy ở thư mục gốc, cài cho cả workspace
```
Tạo các file trong `deploy/secrets/` từ file `*.env.example` tương ứng rồi điền mật khẩu, key.

## Lệnh thường dùng
```
melos run analyze      # phân tích tĩnh
melos run test         # test các service, package
melos run test:app     # test app Flutter
```

## Chạy hệ thống bằng Docker
Chạy từ thư mục gốc, theo thứ tự:
```
# 0. Tải bảng IP → quốc gia cho service geo (một lần mỗi tháng)
bash deploy/scripts/geo-download.sh

# 1. Hub: Postgres + Keycloak (http://localhost:8180, realm tbt) + geo (8190) + audit (8195)
#    + report (8196) + Doris (8030, 8040, 9030; cần khoảng 5 GB RAM, khởi động 1–2 phút)
#    Lần đầu tạo bảng sổ sự kiện: chạy các file services/audit/migrations/*.sql vào audit_db của hub-postgres
docker compose -p tbt-hub -f deploy/compose.hub.yml up -d

# 2. Sinh cấu hình Kong kèm public key của Keycloak (chạy lại khi tạo mới Hub)
bash deploy/scripts/sync-kong-jwt.sh

# 3. Một khu vực, ví dụ VN (Kong ở cổng 8000, kèm sync_worker đẩy sự kiện lên audit ở Hub)
docker compose -p tbt-vn --env-file deploy/regions/vn.env -f deploy/compose.region.yml up -d --build
```
```
# 4. Tạo bảng và nạp dữ liệu mẫu cho khu vực vừa bật (chạy lại được, dữ liệu cũ trong bảng bị thay)
bash deploy/scripts/db-init.sh vn

# 5. Tạo bucket lưu CV trong Garage của khu vực
bash deploy/scripts/garage-init.sh vn
```
Dữ liệu mẫu nằm ở `deploy/seed/<khu vực>/`. Dữ liệu là mô phỏng theo ngôn ngữ từng nước; tỷ giá trong `currency` là số mô phỏng, không phải tỷ giá thật. Muốn sinh lại: `python tools/seed_data/generate.py`.

Đổi `vn` thành `de`, `us`, `br`, `za`, `au` để bật khu vực khác. Mỗi khu vực tốn khoảng 550 MB RAM, Docker 12 GB bật đủ Hub + 6 khu vực được. Cổng công khai mỗi khu vực (VN 8000, DE 8100, US 8200, BR 8300, ZA 8400, AU 8500) là **WAF** (ModSecurity + OWASP CRS), WAF chuyển tiếp vào Kong trong mạng nội bộ. `hr`, `attendance` chạy 2 bản, Kong chia tải. Mỗi khu vực có Redis làm cache. Tạo lại nhiều container cùng lúc thì `docker restart tbt-<khu vực>-kong-1`.

Thông báo đẩy (FCM) cần khóa service account Firebase ở `deploy/secrets/firebase-sa.json`; email cảnh báo cần mật khẩu ứng dụng Gmail ở `deploy/secrets/gmail-app-password.txt`. Thiếu hai file này thì hệ thống vẫn chạy, chỉ không gửi đẩy/email.

Tắt: thay `up -d` bằng `down` (thêm `-v` để xóa luôn dữ liệu).

## Khu vực DE trên Kubernetes
Khu vực DE chạy trên cụm k3s 2 node (dựng bằng [k3d](https://k3d.io), cần `k3d` và `kubectl`). Manifest ở `deploy/k8s/` (kustomize: `base/` dùng chung, `de/` riêng DE; khu vực khác thêm overlay cùng dạng). Cụm dùng lại volume dữ liệu của bản Compose DE, cổng trên máy giữ nguyên (8100, 5434, 3910, 8091, 9190), nên chỉ chạy một trong hai bản.
```
docker compose -p tbt-de --env-file deploy/regions/de.env -f deploy/compose.region.yml stop
bash deploy/k8s/cluster.sh de up        # tạo cụm, nạp image tbt/*, áp manifest
bash deploy/k8s/cluster.sh de status    # pod, service, HPA
bash deploy/k8s/cluster.sh de images    # sau khi build lại image
bash deploy/k8s/cluster.sh de stop      # dừng cụm, giữ dữ liệu
```
Trên Kubernetes, service gọi nhau bằng tên Service (không cần Eureka), liveness probe thay autoheal, `hr` và `attendance` tự tăng tới 4 bản theo CPU (HPA).

## Chạy trên máy chủ thật
`deploy/vps/` gồm Caddy (HTTPS tự động), tường lửa, script đưa cấu hình, image, khóa lên máy chủ và script bật từng phần. Địa chỉ công khai đặt trong `deploy/vps/vps.env` (chép từ `vps.env.example`).
```
bash deploy/vps/push.sh root@<máy chủ> all          # từ máy dev
bash deploy/vps/firewall.sh                          # trên máy chủ, chạy một lần
bash deploy/vps/up.sh all                            # Hub, VN (Compose), DE (k3s), Caddy
```
App trỏ về máy chủ khi build: `--dart-define=KEYCLOAK_URL=https://auth.<tên miền>`, `--dart-define=GEO_URL=https://geo.<tên miền>`, `--dart-define=KONG_URL=https://{region}.<tên miền>`.

## Tài khoản thử trong Keycloak
`anonymous1606` (executive, admin), `hr.vn`, `finance.vn`, `employee.vn`, `hr.de`, `finance.de`, `employee.de`, `hr.us`, `employee.us`, `finance.us` (tương tự cho `br`, `za`, `au`), `auditor.ext` (kiểm toán, hạn tới 2026-12-31). Người tự đăng ký nhận role `candidate`. Mật khẩu ở `deploy/secrets/keycloak.env`.

## Chạy một service không qua Docker
```
cd services/hr
dart_frog dev
```

## Chạy app
Mở thư mục `tbt-center` trong Android Studio hoặc `cd tbt-center && flutter run`.
Máy ảo, điện thoại cắm USB cần chuyển cổng để gọi được Keycloak và Kong trên máy tính:
```
adb reverse tcp:8180 tcp:8180
adb reverse tcp:8000 tcp:8000
adb reverse tcp:8190 tcp:8190
adb reverse tcp:3900 tcp:3900   # Garage VN, để app tải CV lên
```

Kiểm thử bằng giao diện thật trên máy ảo (gọi Keycloak, Kong thật; mật khẩu tài khoản thử chỉ truyền lúc chạy):
```
cd tbt-center
flutter test integration_test/all_roles_test.dart -d emulator-5554 --dart-define=TBT_TEST_PASSWORD=<mật khẩu chung>
flutter test integration_test/actions_test.dart   -d emulator-5554 --dart-define=TBT_TEST_PASSWORD=<mật khẩu chung>
flutter test integration_test/push_test.dart      -d emulator-5554 --dart-define=TBT_TEST_PASSWORD=<mật khẩu chung>
```

## Thử Saga chốt lương và báo cáo hợp nhất
- Đăng nhập `finance.vn`, vào **Chốt lương**, chốt kỳ hiện tại; xem 5 bước chạy.
- Bật lỗi ngân hàng giả lập: `curl -X POST -H "Content-Type: application/json" -d '{"mode":"failing"}' http://localhost:8090/admin/mode`, chốt kỳ khác để thấy bước hoàn tác; đổi lại `"normal"` rồi bấm **Chạy lại**.
- Đăng nhập `anonymous1606`, vào **Báo cáo tập đoàn** để xem số liệu hợp nhất các khu vực (quy USD).

## Thử tài chính, dự án
- Đăng nhập `finance.vn`, vào **Tài chính**: tab Thu chi xem doanh thu, chi phí từng tháng, bấm **Chốt sổ** cho tháng đã qua; tab Nhà cung cấp xem công nợ, ghi mua, trả tiền.
- Tháng đã chốt hiện ở **Báo cáo tập đoàn** sau vài giây (đi qua Outbox → audit → Doris).
- `hr.vn` vào **Dự án và hợp đồng** (không thấy liên hệ khách hàng); `employee.vn` vào **Dự án của tôi**.
- `finance.vn` mở một dự án → **Nghiệm thu**: doanh thu nghiệm thu được ghi vào Tài chính tháng hiện tại, bộ phận tài chính nhận thông báo.
- `employee.vn` vào **Chấm công & nghỉ phép**: thẻ Chấm công hôm nay (bấm lần đầu vào ca, lần hai ra ca), tab Tăng ca để xin tăng ca; `hr.vn` duyệt ở tab Duyệt đơn.
- `hr.vn` vào **Ứng viên** → nút tải tệp ở góc trên để nhập ứng viên từ `.csv`/`.xlsx` (dòng đầu là tên cột: Họ và tên, Email, Số điện thoại, Vị trí ứng tuyển), tick từng người hoặc xác nhận tất cả.
- `auditor.ext` (kiểm toán độc lập, có hạn) hoặc `anonymous1606` vào **Sổ kiểm toán**: lọc theo khu vực, kiểm chuỗi băm, xuất cho kiểm toán (xem mã SHA-256); lãnh đạo xem thêm tab Ai đã truy cập.
- Chuông ở màn chính là hộp thông báo: duyệt đơn, phát lương, hồ sơ ứng viên đổi bước đều báo cho đúng người sau khoảng 5–30 giây.
- Sửa route trong `kong.template.yml` thì chạy lại `sync-kong-jwt.sh` rồi `docker restart tbt-vn-kong-1`.

## Sao lưu và khôi phục
```
bash deploy/scripts/backup.sh vn                                  # mọi database của VN, kèm SHA256SUMS
bash deploy/scripts/restore.sh vn <thời điểm> payroll_db          # khôi phục vào payroll_db_restore_check, so số dòng
bash deploy/scripts/restore.sh vn <thời điểm> payroll_db --drop-check
bash deploy/scripts/restore.sh vn <thời điểm> payroll_db --replace  # ghi đè thật, nên dừng service trước
```
Bản sao lưu nằm ở `deploy/backups/<khu vực>/<thời điểm>/`, không đưa lên git.

## Tài liệu API
`docs/api/openapi.yaml` (OpenAPI 3.1): mọi API đi qua Kong của 6 khu vực, cách xác thực, mã lỗi. Mở bằng https://editor.swagger.io hoặc plugin OpenAPI của IDE.

## Giám sát
- Grafana: http://localhost:3000 (tài khoản dev chung trong `deploy/secrets/grafana.env`), dashboard **TBT Center: tình trạng hệ thống**, chọn khu vực ở ô Khu vực.
- Prometheus từng khu vực: VN http://localhost:9090, DE http://localhost:9190; Hub http://localhost:9099. Trang Alerts hiện cảnh báo đang bật.
- Alertmanager ở Hub http://localhost:9093 gửi email cảnh báo (mẫu HTML) về Gmail; Prometheus Hub và 6 khu vực cùng đẩy cảnh báo về đây.
- Thử cảnh báo: `docker stop tbt-vn-bank_mock-1`, đợi khoảng 2 phút có email `ServiceDown`, rồi `docker start tbt-vn-bank_mock-1` để nhận email đã hồi phục.
- Tự phục hồi: mọi service có healthcheck; container `autoheal` ở Hub tự khởi động lại container bị treo (unhealthy).

## Ghi nguồn
Bảng IP → quốc gia: [IP Geolocation by DB-IP](https://db-ip.com), giấy phép CC BY 4.0.
