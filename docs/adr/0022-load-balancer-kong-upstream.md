# ADR 0022: Cân bằng tải bằng upstream của Kong

Ngày: 2026-10-16. Trạng thái: đã áp dụng.

## Bối cảnh
R46 yêu cầu mở rộng khi người dùng tăng; một bản service chết không được làm gián đoạn. Kong là API Gateway của dự án, có sẵn bộ cân bằng tải.

## Quyết định
- `hr`, `attendance` chạy 2 bản mỗi khu vực (`deploy.replicas: 2`). Kong khai upstream `hr.upstream`, `attendance.upstream`, round-robin; đích là tên DNS, Kong tách theo IP từng bản.
- Health check chủ động (`GET /` mỗi 5 giây, hỏng 2 lần thì bỏ ra) và bị động (lỗi 3 lần trên request thật thì bỏ ra).
- Kong đặt `KONG_DNS_ORDER: LAST,A,CNAME`: mặc định Kong hỏi SRV trước, DNS Docker không có nên chờ khoảng 4 giây ở lần gọi đầu mỗi service.
- Chỉ nhân bản service không giữ trạng thái và không có việc chạy nền đọc sự kiện (notification, report giữ 1 bản).

## Hệ quả
- Đã thử: 20 request chia đều hai bản; tắt một bản, 30/30 request vẫn 200.
- Service khác muốn thêm bản chỉ cần sửa compose và thêm upstream trong `kong.template.yml`, chạy `sync-kong-jwt.sh`.

Yêu cầu liên quan: R46, R50.
