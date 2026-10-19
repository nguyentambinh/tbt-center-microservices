# ADR 0030: Bản thể học, suy luận, AI trích xuất và SPARQL cho đồ thị tri thức

Ngày: 2026-10-18. Trạng thái: đã áp dụng. Nối tiếp ADR 0028.

## Bối cảnh
Đồ thị tri thức ở ADR 0028 đã có nút, cạnh có tên và GraphRAG, nhưng còn 4 chỗ thiếu so với một đồ thị tri thức đầy đủ: chưa có bản thể học chuẩn (RDF/OWL), chưa có suy luận tự động, nút và cạnh đều do người soạn tay, đồ thị nhỏ (74 nút, 128 cạnh), chỉ đi được 2 bước và chỉ truy vấn được bằng SQL.

## Quyết định
- **Bản thể học trong PostgreSQL, xuất được OWL 2.** Bảng `kg_classes` lưu cây 21 lớp. Ví dụ: Đơn yêu cầu, Khoản tiền, Hồ sơ dữ liệu là lớp con của Khái niệm; Quy trình và Bước là lớp con của Hoạt động. `kg_relations` có 32 quan hệ, mỗi quan hệ có miền (domain), phạm vi (range) và các tính chất bắc cầu, đối xứng, chiều ngược, kéo theo. Mọi cạnh đều phải đúng miền và phạm vi: `build.py` kiểm khi sinh đồ thị, server kiểm khi AI đề xuất và khi HR duyệt. `GET /knowledge/ontology?format=turtle` xuất Turtle (RDF 1.1): lớp là `owl:Class`, quan hệ là `owl:ObjectProperty`, miền gồm nhiều lớp thì ghi bằng `owl:unionOf`, luật chuỗi ghi bằng `owl:propertyChainAxiom`, giá trị trên cạnh ghi bằng `owl:Axiom`. File này mở được bằng Protégé hay rdflib.
- **Suy luận tiến (forward chaining) tự viết bằng Dart**, theo 17 luật trong `kg_rules`. Các luật chỉ dùng loại mà OWL 2 RL cũng có: bắc cầu, đối xứng, chiều ngược, kéo theo (subPropertyOf) và chuỗi quan hệ (property chain). Ví dụ:
  - Quy trình có bước do service S xử lý thì quy trình có sự tham gia của S.
  - Quy trình cần S, S gọi T thì quy trình cũng cần T.
  - Được xem cái tổng thì được xem phần nằm trong nó.
  
  Cạnh suy ra lưu với `origin = inferred`, ghi kèm luật và các cạnh làm tiền đề, nên app giải thích được "vì sao". Luật nào sinh ra cạnh sai miền hoặc phạm vi thì cạnh đó bị loại và ghi lý do. Suy luận chạy khi service bật, sau mỗi lần HR duyệt đề xuất, và khi gọi `POST /knowledge/reasoner`.
- **AI trích xuất, người duyệt** (R51):
  - Bước 1: AI đọc bài viết (Claude, lỗi thì lần lượt các model Gemini, mỗi model một Circuit Breaker) và trả JSON đúng khuôn. Khuôn chỉ cho phép các lớp và quan hệ có trong bản thể học.
  - Bước 2: server kiểm từng đề xuất: miền và phạm vi của quan hệ, câu trích phải có thật trong bài (so sau khi bỏ dấu), độ tin cậy từ 0,5 trở lên, nút mới phải được cạnh hợp lệ nào đó dùng tới, cạnh đã có thì bỏ qua.
  - Bước 3: đề xuất hợp lệ chờ HR, quản trị hoặc ban điều hành duyệt (`/knowledge/proposals`). Duyệt xong mới vào đồ thị (`origin = extracted`, kèm câu trích) và máy suy luận lại.
  - Việc nền mỗi 6 giờ đọc bài mới hoặc bài vừa sửa (so dấu băm nội dung). Mỗi lượt đọc tối đa 3 bài để không hết hạn mức AI.
- **SPARQL tự viết, chạy trên đồ thị trong bộ nhớ**, đặt ở `POST /knowledge/sparql`. Chỉ đọc, hỗ trợ một tập con của SPARQL 1.1:
  - `SELECT` (có `DISTINCT`, `*`, `COUNT ... GROUP BY`), mẫu bộ ba.
  - Đường thuộc tính `/ | ^ * + ?`.
  - `FILTER` (so sánh, `CONTAINS`, `REGEX`, `LANG`...), `OPTIONAL`, `UNION`, `ORDER BY`, `LIMIT`, `OFFSET`.
  - `a` hiểu theo suy luận RDFS: nút thuộc mọi lớp cha của nó.
  
  Ngoài SPARQL, `GET /graph/{id}?to=...` tìm đường ngắn nhất (BFS tới 6 bước), còn `depth` của nút lân cận tăng lên 3.
- **Mở rộng đồ thị**: thêm cả 16 service, 21 công nghệ, 15 mẫu kiến trúc, đồng tiền và ngôn ngữ của từng nước, tài chính, dự án, giám sát và chính kho tri thức. Kết quả 167 nút, 484 cạnh soạn sẵn, cộng 222 cạnh suy ra. Viết thêm 5 bài (nhà cung cấp, chốt sổ, nghiệm thu, quyền xem, đồ thị tri thức) để AI có tài liệu mà trích xuất.
- App: menu ở màn Kho tri thức có Bản thể học, Truy vấn SPARQL (kèm 5 câu mẫu) và Đề xuất từ AI (chỉ HR, quản trị, ban điều hành thấy). Trên hình đồ thị, cạnh suy ra vẽ nét đứt. Chạm vào cạnh suy ra thì thấy luật và các cạnh tiền đề; chạm vào cạnh AI trích thì thấy câu trích. Nút "Nối tới…" tìm đường nối giữa hai khái niệm.

## Vì sao không dùng Neo4j, GraphDB hay Apache Jena
- Đồ thị dưới 1.000 cạnh, mỗi lần suy luận chỉ mất khoảng 20 ms. Thêm một kho RDF hay kho đồ thị (Jena Fuseki, GraphDB, Neo4j) là thêm một tiến trình Java tốn vài trăm MB RAM trên máy 24 GB vốn đã gần hết. Thêm nữa là một nơi phải sao lưu và giám sát.
- Không bị khóa vào công cụ: dữ liệu xuất ra Turtle chuẩn, ai muốn chạy SPARQL đầy đủ thì nạp file đó vào Jena hay GraphDB là được.
- Có kiểm chéo bằng công cụ chuẩn. Kịch bản kiểm dùng rdflib đọc Turtle, rồi để `owlrl` (bộ suy luận OWL 2 RL của Python) suy luận lại từ đầu. Kết quả: owlrl ra đúng **222 cạnh mới, trùng hoàn toàn** với bộ suy luận Dart. 5 câu SPARQL chạy trên service và trên rdflib cho kết quả giống nhau.

## Hệ quả
- Lần chạy thật đầu tiên: AI đọc 15 bài trong khoảng 11 phút và đề xuất 62 mục. Server giữ lại **55 mục hợp lệ** và **tự loại 7 mục**: 4 mục nối sai miền hoặc phạm vi, 3 nút mới không được cạnh nào dùng. Lần này chỉ Gemini chạy vì tài khoản Anthropic đang hết credit.
- AI có thể đề xuất đúng câu chữ nhưng sai ý. Ví dụ bài viết ghi "HR hoặc quản lý duyệt đơn", AI đề xuất thêm vai trò "Quản lý", trong khi hệ thống không có vai trò này. Vì vậy bắt buộc phải có người duyệt; server chỉ chặn được các lỗi về hình thức.
- Câu trả lời của AI hỏi đáp giờ có thêm cạnh suy ra (ghi chữ "inferred"). Tiền tố cache tăng lên `kb:qa:v4`.
- SPARQL tự viết chưa có `CONSTRUCT`, `ASK`, `BIND`, `VALUES`, truy vấn con, và chưa có hàm gộp nào ngoài `COUNT`. Câu nào ngoài tập con thì server báo `bad_query` kèm lý do.
- Suy luận mới làm đến OWL 2 RL qua luật, chưa có lớp tách rời (disjoint) và ràng buộc số lượng (cardinality).

Yêu cầu liên quan: R51 (tri thức nội bộ, phản hồi), R57, R59 (tra cứu quy định), R45 (giám sát, tra cứu thành phần hệ thống).
