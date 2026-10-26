# ADR 0032: Khu vực Đức chạy trên Kubernetes (k3s, dựng bằng k3d)

Ngày: 2026-10-25. Trạng thái: đã áp dụng cho khu vực DE; Hub và 5 khu vực còn lại chạy Docker Compose trên máy dev.

## Bối cảnh
Thiết kế triển khai đặt mỗi khu vực trên một cụm Kubernetes. Bản Docker Compose thiếu những thứ Kubernetes làm sẵn: tự khởi động lại pod treo (phải bù bằng autoheal), tìm service theo tên (phải bù bằng Eureka), chia tải giữa các bản (phải nhờ upstream của Kong), tự tăng số bản khi tải cao. Máy dev có 24 GB RAM, WSL giới hạn 12 GB: Hub cùng một cụm khu vực chạy được, 6 cụm cùng lúc thì không đủ RAM.

## Quyết định
- Khu vực DE chạy trên cụm k3s 2 node (1 server, 1 agent) do k3d dựng trong Docker. k3s là bản Kubernetes gọn (bỏ traefik vì đã có Kong).
- Manifest viết bằng kustomize: `deploy/k8s/base` dùng chung mọi khu vực, `deploy/k8s/de` là overlay (namespace `tbt-de`, ConfigMap từ `deploy/regions/de.env`, Secret sinh thẳng từ `deploy/secrets`, không lên git). Khu vực khác chỉ cần thêm một overlay cùng dạng.
- Service không giữ trạng thái là Deployment + Service ClusterIP; Postgres primary, replica, Garage là StatefulSet; dữ liệu là PersistentVolume trỏ vào đúng volume Docker của bản Compose cùng khu vực (gắn vào node server), PVC chỉ định PV bằng `volumeName`.
- Service gọi nhau bằng tên Service (DNS của cụm): không đặt `EUREKA_URL`, Eureka và autoheal không cần trong cụm. Readiness probe quyết định pod nào được nhận request; liveness probe khởi động lại pod treo.
- `hr`, `attendance` 2 bản, HorizontalPodAutoscaler tăng tới 4 khi CPU trung bình quá 70%; PodDisruptionBudget giữ ít nhất 1 bản khi cập nhật.
- Chỉ WAF mở ra ngoài cụm (NodePort 30800, k3d chuyển cổng Kong công khai của khu vực vào). Cổng của máy giữ như bản Compose (DE: 8100, 5434, 3910, 8091, 9190) để app và Grafana ở Hub không phải đổi.
- Prometheus của khu vực tìm pod qua API của cụm (`kubernetes_sd_configs`, Role chỉ đọc pod trong namespace), mỗi bản pod là một target.
- Pod gọi Hub qua `host.docker.internal` (Docker Desktop phân giải được trong pod).

## Hệ quả
- Đã chạy thật: 20 pod chia trên 2 node; qua WAF → Kong không token trả 401, có token trả 200, sai vai trò trả 403; replica `streaming`; sync_worker đẩy sự kiện lên audit và đọc kho tổng về; Prometheus 12/12 target `up`; HPA đọc được CPU; E2E giao diện thật 3 vai trò qua. Xóa một pod `hr` trong lúc gửi 40 request: 40/40 thành công, Deployment tự tạo pod thay thế.
- RAM: một cụm khu vực khoảng 2,8 GB (pod ứng dụng khoảng 0,8 GB, phần còn lại là k3s của 2 node), nhiều hơn bản Compose cùng khu vực.
- Bản Compose và cụm k3d của cùng khu vực dùng chung volume dữ liệu nên chỉ chạy một bản: `cluster.sh` từ chối tạo hoặc bật cụm khi Compose của khu vực đó đang chạy.
- Image `tbt/*` build bằng Docker phải nạp vào cụm (`cluster.sh de images`). Docker Desktop dùng kho image containerd nên phải lưu bản `linux/amd64` trước khi nạp.
- Kong vẫn giữ upstream có health check; trong cụm đích là ClusterIP nên phần chia tải thật do Service làm.

Lệnh: `bash deploy/k8s/cluster.sh de up | apply | images | status | stop | start | down`.

Yêu cầu liên quan: R45, R46, R48, R49, R50, R69.
