# ADR 0019: Thông báo đẩy qua FCM HTTP v1, server tự ký JWT

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Hộp thông báo trong app chỉ thấy khi mở app. R18, R97 cần báo ngay cả khi app đang tắt. Android nhận thông báo đẩy qua Firebase Cloud Messaging (FCM) của Google.

## Quyết định
- Firebase project `tbt-center-nhom16`; app dùng `firebase_core`, `firebase_messaging`. Đăng nhập thì gửi mã máy (FCM token) lên `notification` của khu vực (`POST /devices`, kèm ngôn ngữ); đăng xuất thì bỏ mã.
- Server lưu mã máy kèm **địa chỉ nhận** của người đó (`role:hr`, `employee:<mã>`, `candidate:<mã>`), gửi tới mọi máy có địa chỉ khớp thông báo mới.
- Gọi FCM HTTP v1 trực tiếp: tự ký JWT RS256 bằng khóa service account (`signRs256` trong `tbt_common`), đổi lấy token Google (lưu 1 giờ). Không dùng thư viện Admin SDK (Dart server không có bản chính thức).
- Câu đẩy viết sẵn 4 ngôn ngữ ở server (chép từ chuỗi `n...` của app). Mã máy Google báo `UNREGISTERED` thì xóa.
- Khóa nằm ở `deploy/secrets/firebase-sa.json` (chặn git); không có file thì chỉ ghi log.

## Hệ quả
- Đã thử qua giao diện thật trên máy ảo: nhân viên xin nghỉ, 9 giây sau app HR hiện thông báo.
- App vẫn dùng `getToken` (đã bị đánh dấu deprecated) vì chắc chắn FCM v1 nhận; API mới `register()` trả Firebase Installation ID, cần kiểm tra thêm cách gửi phía server trước khi đổi.
- Máy không có Google Play services thì không có thông báo đẩy, app vẫn chạy.

Yêu cầu liên quan: R18, R97.
