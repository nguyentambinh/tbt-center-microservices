# ADR 0015: Quyền kiểm toán có thời hạn, nhật ký truy cập, xuất kèm SHA-256

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Yêu cầu kiểm toán: đọc sổ qua API chỉ đọc; đơn vị kiểm toán độc lập chỉ được cấp quyền giới hạn, có thời hạn (R88); mọi lần họ truy cập đều được ghi lại (R90); dữ liệu xuất cho kiểm toán kèm giá trị kiểm tra (checksum), sửa sau khi xuất sẽ bị phát hiện (R89). Sổ audit ở Hub chỉ nhận `X-Sync-Token` của máy, chưa có quyền cho người.

## Quyết định
- Thêm vai trò `auditor` trong Keycloak. Tài khoản kiểm toán độc lập mang thuộc tính `access_until` (YYYY-MM-DD), đưa vào token qua mapper. Service audit từ chối (403 `access_expired`) khi đã quá hết ngày đó; lãnh đạo, quản trị không cần hạn. Tài khoản thử: `auditor.ext`, hạn 2026-12-31.
- Đường `/audit-log` của service audit dùng token người dùng (kiểm chữ ký bằng JWKS, ADR 0014), đi qua Kong khu vực ở `/audit`. Các đường cũ (`/events`, `/verify`) vẫn chỉ dành cho máy, dùng `X-Sync-Token`.
- `GET /audit-log` (tra cứu theo khu vực, loại sự kiện, ngày), `GET /audit-log/verify` (tính lại chuỗi băm), `GET /audit-log/export` (CSV có cả `prev_hash`, `hash`; mã SHA-256 của tệp ở header `X-Checksum-SHA256`).
- Mỗi lần tra cứu, kiểm, xuất đều ghi vào bảng `access_log` (ai, vai trò, việc gì, điều kiện lọc, số dòng, mã SHA-256 của tệp đã xuất). Bảng này cũng chỉ ghi thêm (trigger chặn sửa, xóa). `GET /audit-log/access` chỉ lãnh đạo, quản trị xem; kiểm toán viên không xem được nhật ký của chính mình.
- App có màn "Sổ kiểm toán" cho executive, admin, auditor; vai trò `auditor` có đá Thạch anh tím (#B39DDB, tương phản 7,58 trên nền thẻ) và không thấy chấm công, phiếu lương.

## Hệ quả
- Đã thử thật: `auditor.ext` tra cứu, kiểm chuỗi (26/26 khớp), xuất 23 dòng; SHA-256 ở header trùng với mã tính lại trên tệp tải về. HR bị 403. Lãnh đạo thấy đủ 3 lần truy cập của kiểm toán viên kèm mã của tệp.
- Chưa có: ký số tệp xuất bằng khóa riêng (Vault/KMS), lưu trữ WORM, biên bản trích xuất dạng PDF.

Yêu cầu liên quan: R42, R52, R53, R54, R88, R89, R90.
