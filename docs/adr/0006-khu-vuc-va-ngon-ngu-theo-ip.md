# ADR 0006: Khu vực và ngôn ngữ mặc định theo IP

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Ứng viên tự đăng ký chưa thuộc khu vực nào, nhưng hồ sơ phải nằm ở một khu vực. Người dùng ở nhiều nước cần app hiển thị đúng ngôn ngữ.

## Quyết định
- Service `geo` ở Hub tra IP ra quốc gia bằng bảng DB-IP Lite (CC BY 4.0) nạp vào bộ nhớ, rồi chọn khu vực gần nhất theo châu lục và ngôn ngữ mặc định.
- App tự hỏi IP công khai của máy (bật VPN thì là IP của VPN) rồi gửi cho `geo`, vì server chạy trên máy dev chỉ thấy IP nội bộ.
- Ngôn ngữ người dùng tự chọn được ưu tiên hơn IP. Bản debug có mục giả lập IP hoặc mã nước để test.
- Nhân viên luôn ghi dữ liệu về khu vực trong claim `region` của token. Ứng viên chưa có `region` thì nộp về khu vực theo IP; service nhận token không có `region` qua tùy chọn `allowNoRegion`.

## Hệ quả
Ngôn ngữ hiển thị và nơi lưu dữ liệu là hai việc tách rời: đổi ngôn ngữ hay bật VPN không làm dữ liệu nhân viên chạy sang khu vực khác.

Yêu cầu liên quan: R05, R09, R57.
