# ADR 0018: Nhận ứng viên vào làm, cấp tài khoản qua Keycloak Admin API

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Ứng viên được nhận phải trở thành nhân viên: có hồ sơ ở `hr`, đăng nhập được với vai trò employee, không còn là candidate. Ba việc nằm ở ba hệ thống (recruitment, hr, Keycloak). Tên đăng nhập là email của ứng viên.

## Quyết định
- `POST /candidates/{id}/hire` ở recruitment (hr, admin, executive), chỉ cho ứng viên ở bước `offered`. Bước `hired` không đổi được qua `/status`.
- Thứ tự: tạo nhân viên ở hr (`POST /internal/employees`, mã cố định `TBT` + 8 ký tự đầu mã ứng viên) → đổi tài khoản Keycloak → đổi bước `hired`, ghi lịch sử, Outbox `CandidateStatusChanged`.
- Keycloak gọi bằng client `tbt-identity` (client credentials), chỉ có `manage-users`, `view-users`, `query-users`, `view-realm` (quyền tối thiểu). Ứng viên đã có tài khoản: đặt email, thêm role employee, gỡ candidate và `default-roles-tbt`, giữ mật khẩu. Chưa có tài khoản (HR nhập): tạo tài khoản username = email, mật khẩu tạm bắt đổi lần đầu, trả cho HR một lần.
- Người trong công ty không mang role candidate (Keycloak gỡ, app lọc thêm).

## Vì sao không dùng Saga
Mỗi bước gọi lại được mà không tạo trùng (mã nhân viên cố định, tài khoản tìm theo email), nên lỗi giữa chừng thì HR bấm lại là xong; không có bước nào không lấy lại được như chuyển tiền (ADR 0009).

## Hệ quả
- Đã thử qua giao diện thật: HR chuyển ứng viên sang mời nhận việc rồi nhận vào làm, app hiện email đăng nhập và mật khẩu tạm; nhân viên mới đăng nhập bằng email, vào được Chấm công.
- Thao tác mất khoảng 2 giây (nhiều lời gọi Keycloak), nút có vòng xoay và khóa trong lúc chờ.
- Keycloak hỏng thì trả 502 `identity_unavailable`, nhân viên đã tạo vẫn giữ, bấm lại an toàn.

Yêu cầu liên quan: R14, R85, R96, R97.
