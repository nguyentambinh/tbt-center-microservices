# ADR 0028: Đồ thị tri thức và hỏi đáp AI (GraphRAG) trong kho tri thức

Ngày: 2026-10-17. Trạng thái: đã áp dụng. Mở rộng ADR 0027.

## Bối cảnh
Bình chốt loại CSDL tri thức: làm cả đồ thị tri thức lẫn hỏi đáp AI, bản tốt nhất có thể. Kho tri thức ở ADR 0027 chỉ tìm theo từ: hỏi "làm thêm giờ" không ra bài "tăng ca", hỏi tiếng Đức không ra bài vì bài chỉ có tiếng Việt và tiếng Anh. Người dùng cũng muốn hỏi bằng câu tự nhiên thay vì đọc cả bài.

## Quyết định
- **Đồ thị tri thức trong PostgreSQL** (`knowledge_db`): bảng `kg_nodes` (74 nút: khái niệm, quy tắc, bước, quy trình, vai trò, service, nước, bài viết), `kg_edges` (128 cạnh), `kg_relations` (18 loại quan hệ, nhãn 4 ngôn ngữ). Dữ liệu sinh từ `tools/knowledge_graph/build.py`, quan hệ lấy đúng theo code (ví dụ ai được duyệt đơn lấy từ `managerRoles`). Không thêm Neo4j: đồ thị nhỏ, truy vấn 1–2 bước bằng SQL đủ nhanh, đỡ một hệ thống tốn RAM.
- **Tìm theo 3 đường rồi gộp**: từ khóa (tsvector, câu hỏi dài nối từ bằng OR), theo nghĩa (vector `gemini-embedding-2` 768 chiều lưu ở `article_embeddings`, so cosine trong Dart), theo đồ thị (khái niệm nhận ra trong câu hỏi qua tên gọi khác đã bỏ dấu → bài giải thích nó và nút lân cận). Gộp bằng Reciprocal Rank Fusion, lấy 4 bài.
- **AI trả lời có trích dẫn**: đưa cho AI các bài đánh số [n] và các sự kiện đồ thị ("Đơn nghỉ phép —do ai duyệt→ HR"). AI phải trả JSON đúng schema (`answerable`, `answer`, `citations`, `followUps`), chỉ dùng nguồn được đưa; số nguồn không có thật bị server bỏ.
- **Ba lớp dự phòng**: Claude Opus 5.5 (`claude-opus-5-5`, effort low, `fallbacks: "default"`) → Gemini, thử lần lượt `gemini-3.8-flash`, `gemini-3.5-flash`, `gemini-2.5-flash` (`GEMINI_QA_MODELS`; bản miễn phí giới hạn lượt mỗi ngày theo từng model) → không có AI thì trả đoạn trích bài khớp nhất kèm sự kiện đồ thị. Mỗi AI có Circuit Breaker riêng, mỗi lần gọi tối đa 25 giây để không vượt giới hạn 60 giây của Kong/WAF.
- **Hội thoại**: app gửi 4 lượt gần nhất; câu nối tiếp ("còn đơn tăng ca thì sao?") tìm theo câu hiện tại trước, câu trước chỉ bổ sung hoặc dùng khi câu hiện tại không tự nhận ra chủ đề.
- **Cache Redis** 6 giờ cho câu hỏi không có lịch sử, khóa gồm phiên bản nội dung (bài hoặc đồ thị đổi là hết hiệu lực). **Giới hạn** 10 câu/phút mỗi người.
- **Nhật ký và phản hồi** (`qa_log`): câu hỏi, nguồn, AI nào trả lời, thời gian, người dùng chấm hữu ích/chưa đúng; `GET /ask/stats` cho HR thấy câu hỏi chưa trả lời được để bổ sung bài (R51). Tự xóa sau 90 ngày.
- **App**: màn Kho tri thức có 3 tab: Hỏi AI (số trích dẫn chạm được, nguồn kèm cách tìm ra, sự kiện đồ thị, gợi ý hỏi tiếp, chấm điểm), Tìm bài, Đồ thị (vẽ bằng CustomPainter, bố trí hình tia trên elip, tránh chồng chữ, tối đa 14 nút quanh tâm, danh sách liên kết đầy đủ bên dưới).

## Hệ quả
- Chạy thật: hỏi tiếng Việt và tiếng Đức đều ra đúng bài; tiếng Đức không khớp từ khóa nhưng tìm theo nghĩa và đồ thị vẫn tìm được. Câu hỏi ngoài phạm vi (giá vàng) được từ chối. Gemini trả lời 2–7 giây, lấy từ cache dưới 50 ms.
- Claude hết hạn mức thì Gemini trả lời; mạch đóng lại thì Claude dùng tiếp.
- Câu hỏi được gửi tới nhà cung cấp AI ở nước ngoài; app chỉ gửi câu hỏi và bài nội bộ, không gửi dữ liệu cá nhân trong CSDL. Câu hỏi người dùng tự gõ có thể chứa thông tin cá nhân, cần nêu trong chính sách sử dụng (Cần kiểm tra).
- Prompt hệ thống ngắn hơn ngưỡng tối thiểu để cache của Claude (512 token) nên chưa được cache; đánh dấu sẵn để khi prompt dài ra thì tự cache.
- Bài viết vẫn thêm bằng migration; đồ thị sửa bằng bộ sinh.

Yêu cầu liên quan: R51 (thu thập phản hồi người dùng), R57 (quy định riêng từng nước), R59 (thư viện tra cứu quy định theo từng quốc gia; mới có hạ tầng và quy tắc nội bộ, chưa nạp văn bản pháp lý thật).
