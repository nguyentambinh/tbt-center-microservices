# ADR 0027: Kho tri thức nội bộ ở Hub, tìm toàn văn bằng PostgreSQL

Ngày: 2026-10-16. Trạng thái: đã áp dụng, mở rộng bởi ADR 0028 (đồ thị tri thức và hỏi đáp AI).

## Bối cảnh
Cần một CSDL tri thức. Nhân viên và HR thường hỏi lại cùng các câu: tăng ca tính thế nào, vì sao không duyệt được đơn lúc đang chốt lương, nghỉ phép bao nhiêu ngày. Câu trả lời đang nằm rải rác trong code, ADR và đầu người.

## Quyết định
- Service `knowledge` đặt ở Hub (cổng 8198), CSDL riêng `knowledge_db` trên Postgres của Hub. Bài viết dùng chung cho cả tập đoàn; bài có `region` chỉ hiện cho nhân viên nước đó.
- Mỗi bài có bản theo ngôn ngữ (`lang`); chưa có bản tiếng Đức, tiếng Bồ Đào Nha thì trả bản tiếng Anh.
- Tìm toàn văn bằng `tsvector` của PostgreSQL, cột `search` sinh sẵn có chỉ mục GIN, tiêu đề nặng hơn thân bài. Hàm `kb_unaccent` (dựa trên `unaccent`) bỏ dấu cả bài lẫn câu hỏi, nên gõ "tang ca" vẫn ra "tăng ca". `ts_headline` trả đoạn trích có từ khớp bọc `<< >>`, app đổi thành chữ đậm.
- App gọi qua Kong của khu vực (`/knowledge`), cùng JWT và WAF như mọi service; chỉ nhân sự (không phải ứng viên, kiểm toán ngoài) mới thấy thẻ.
- Không thêm Elasticsearch: 10–100 bài thì Postgres là đủ, bớt một hệ thống phải chạy và giám sát.

## Hệ quả
- Đã chạy thật: 10 bài × 2 ngôn ngữ (vi, en); E2E trên máy ảo gõ "tang ca" ra đúng bài, mở xem được nội dung.
- Tìm theo từ, chưa hiểu nghĩa: hỏi "làm thêm giờ" không ra bài "tăng ca" nếu bài không chứa cụm đó. Hướng nâng cấp: thêm từ đồng nghĩa (thesaurus) hoặc tìm theo vector (pgvector) và hỏi đáp AI.
- Chưa có màn soạn bài; bài thêm bằng migration SQL.

Yêu cầu liên quan: R59 (thư viện tra cứu quy định theo từng quốc gia, một phần), R57 (bài theo `region`).
