# ADR 0003: CV lưu ở Garage (chuẩn S3) riêng từng khu vực

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Các phương án cân nhắc: MinIO/S3, Firebase Storage. MinIO bản cộng đồng đã ngừng phát hành image Docker và kho mã đã chuyển sang chỉ đọc (2025–2026).

## Quyết định
- Mỗi khu vực một Garage (v2.3.0, chuẩn S3), bucket `tbt-cv`. CV của ứng viên nằm ở khu vực nhận hồ sơ, không rời khu vực.
- App tải CV thẳng lên Garage bằng URL ký sẵn (AWS Signature V4, hết hạn 10 phút) do `recruitment` cấp; file không đi qua Kong hay service.
- Sau khi tải, `recruitment` đọc lại file, kiểm tra đúng PDF và tối đa 10 MB, lưu mã băm SHA-256 vào database.
- HR mở CV bằng URL ký sẵn chỉ đọc, hết hạn sau 5 phút.

## Hệ quả
- Đáp ứng yêu cầu dữ liệu cá nhân nằm tại nước sở tại (ví dụ GDPR ở DE).
- Kong và service không phải gánh file lớn.
- Phải tự viết phần ký URL SigV4 vì Dart không có SDK S3 chính thức.

Yêu cầu liên quan: R96, R98, R56, R57.
