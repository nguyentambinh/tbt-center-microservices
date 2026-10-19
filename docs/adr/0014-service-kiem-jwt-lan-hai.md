# ADR 0014: Service tự kiểm chữ ký JWT lần hai

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Kong ở mỗi khu vực đã kiểm chữ ký và hạn của token (plugin jwt, RS256). Service chỉ đọc nội dung token và tin Kong thì khi ai đó vào được mạng nội bộ của khu vực và gọi thẳng service (không qua Kong), họ có thể tự chế token có vai trò `admin`. Cần kiểm token ở từng request, đặt trong `packages/common` (JWT verify qua JWKS Keycloak).

## Quyết định
- `JwtVerifier` trong `tbt_common` kiểm: thuật toán `RS256`, người phát hành (`JWT_ISSUER`), hạn (`exp`), và chữ ký theo khóa công khai lấy từ JWKS của Keycloak (`JWT_JWKS_URL`).
- Tự viết phần kiểm chữ ký RSA PKCS#1 v1.5 + SHA-256 (`verifyRs256`) bằng `BigInt.modPow`, vì không có thư viện RSA trong cache. Phép kiểm chỉ dùng khóa công khai, không có bí mật nào; so sánh không dừng sớm.
- Khóa công khai được nhớ lại. Gặp `kid` lạ (Keycloak đổi khóa) thì tải lại, nhưng không quá một lần mỗi 30 giây.
- `requireClaims` tự dùng bộ kiểm khi có cấu hình. Không có cấu hình (chạy test, chạy riêng một service) thì đọc token như trước.
- Chưa tải được khóa (Hub mất kết nối lúc service vừa bật) thì trả 503 `auth_unavailable`. Không cho qua khi chưa kiểm được.

## Hệ quả
- Token giả hoặc bị sửa (ví dụ tự đổi `hr` thành `admin` rồi giữ chữ ký cũ) bị chặn ở cả Kong lẫn service. Test dùng khóa RSA tạo riêng bằng openssl, không cần mạng.
- Service ở khu vực phụ thuộc Keycloak ở Hub đúng một lần lúc khởi động, để tải khóa. Sau đó khóa nằm trong bộ nhớ, Hub mất kết nối vẫn kiểm được token.
- Mỗi request tốn thêm một phép tính RSA (vài phần nghìn giây).

Yêu cầu liên quan: R14, R41, R43, R58.
