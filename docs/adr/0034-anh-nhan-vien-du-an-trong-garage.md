# ADR 0034: Ảnh nhân viên, dự án lưu trong Garage của từng khu vực, đọc bằng URL ký sẵn

Ngày: 2026-10-25. Trạng thái: đã áp dụng cho VN, DE trên máy chủ thật.

## Bối cảnh
Hồ sơ nhân viên và dự án cần ảnh để hiển thị trong app. Ảnh nhân viên là dữ liệu cá nhân, phải ở lại khu vực như các dữ liệu cá nhân khác. Mỗi khu vực đã có Garage (S3) để lưu CV ứng viên.

## Quyết định
- Mỗi khu vực một bucket `tbt-media` trong Garage của khu vực đó; object đặt tên theo mã: `employees/<mã nhân viên>.jpg`, `projects/<mã dự án>.jpg`.
- CSDL chỉ lưu đường dẫn object: cột `employees.photo_url` (hr) và cột mới `projects.image_key` (project_contract, migration `006_project_image.sql`).
- API trả URL ký sẵn (AWS Signature V4) thay cho đường dẫn; app tải ảnh thẳng từ Garage, không đi qua service. Bộ ký dùng chung `MediaStore` trong `tbt_common` (cùng bộ ký với CV ứng viên).
- URL ký theo mốc đầu ngày (UTC), hạn 2 ngày: trong cùng một ngày URL không đổi nên app lưu đệm được ảnh; sang ngày mới URL đổi.
- Ảnh được chuẩn bị trước bằng `tools/media/build_media.py` (cắt vuông 512 px cho nhân viên, 1280×720 cho dự án, chọn ảnh công trình theo loại suy ra từ tên dự án) và tải lên bằng `tools/media/upload_s3.py`.
- Nhân viên thường xem được chi tiết dự án mình tham gia (`GET /projects/{id}` kiểm thành viên), không thấy tiền cọc, giá trị nghiệm thu, lương dự án của đồng nghiệp; dự án khác trả 403.

## Hệ quả
- Ảnh không rời khu vực; người khu vực khác không có URL ký của khu vực này.
- Service không phải truyền byte ảnh, không làm chậm Kong; ảnh nhân viên khoảng 35–45 KB, ảnh dự án 100–200 KB.
- Thiếu khóa S3 hoặc chưa có ảnh thì API trả `null`, app hiện chữ viết tắt hoặc biểu tượng công trình.
- Khu vực chạy phiên bản cũ của CSDL phải chạy migration `006_project_image.sql` trước khi dùng bản project_contract mới.

Yêu cầu liên quan: R13, R14, R26, R38, R100.
