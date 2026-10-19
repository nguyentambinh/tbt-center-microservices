# ADR 0001: Backend viết bằng Dart (dart_frog) thay cho Spring Boot

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Phương án phổ biến cho microservice là Spring Boot. Nhóm có hai người, cùng lúc làm app Flutter và hệ thống phân tán.

## Quyết định
Mọi service viết bằng Dart với dart_frog, chung một pub workspace với app, quản lý bằng melos. Phần dùng chung đặt ở `packages/common` (kết nối database, middleware xác thực, Idempotency, Outbox, Circuit Breaker).

## Hệ quả
- Một ngôn ngữ cho cả app và server; DTO, cách đặt tên, cách test giống nhau.
- Hệ sinh thái Dart phía server nhỏ hơn Java: một số phần phải tự viết (ký URL S3, Circuit Breaker, gọi Claude API qua HTTP).
- Mỗi service vẫn là một tiến trình, một image Docker, một database riêng, nên mẫu Microservices không đổi.

Yêu cầu liên quan: R46, R50.
