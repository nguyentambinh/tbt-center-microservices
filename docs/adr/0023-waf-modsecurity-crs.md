# ADR 0023: WAF ModSecurity + OWASP CRS trước Kong

Ngày: 2026-10-16. Trạng thái: đã áp dụng.

## Bối cảnh
Kong bản miễn phí kiểm token, giới hạn tần suất nhưng không đọc nội dung request để bắt tấn công web. R14, R98 yêu cầu bảo mật dữ liệu nhân sự, ứng viên.

## Quyết định
- Mỗi khu vực một container `owasp/modsecurity-crs:nginx-alpine` (Nginx + ModSecurity + OWASP Core Rule Set) giữ cổng công khai; Kong chỉ mở cổng nội bộ. Đường đi: App → WAF → Kong → service.
- Paranoia level 1, chặn khi điểm bất thường ≥ 5; mở thêm `PUT PATCH DELETE` vì app dùng.
- Log kiểm tra dạng JSON để biết luật nào chặn.

## Hệ quả
- Đã thử: SQL injection, XSS (tham số và body JSON), path traversal, User-Agent `sqlmap` đều 403; request thường chậm thêm khoảng 5 ms.
- Chạy lại toàn bộ E2E (28 ca, 6 nước) qua WAF: không chặn nhầm request nào của app.
- Nếu sau này chặn nhầm, xem log rồi nới đúng luật đó, không tắt WAF.

Yêu cầu liên quan: R14, R73, R98.
