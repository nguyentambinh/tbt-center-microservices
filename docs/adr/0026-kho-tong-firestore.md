# ADR 0026: Kho dữ liệu tổng trên Firestore, Hub ghi, khu vực đọc, mã hóa theo từng nước

Ngày: 2026-10-16. Trạng thái: đã áp dụng.

## Bối cảnh
Cần một kho dữ liệu tổng của toàn bộ các nước trên Firebase: các nước đọc từ đó để cập nhật, đồng bộ; muốn ghi thì gửi lên Hub, Hub chịu trách nhiệm ghi lên Firebase; bảo mật là yêu cầu quan trọng. Kiến trúc đã chốt giữ dữ liệu cá nhân ở nước sở tại (GDPR), nên đưa toàn bộ dữ liệu lên một đám mây chung phải có lớp bảo vệ riêng.

## Quyết định
- Firestore (project `tbt-center-nhom16`, vùng asia-southeast1 gần Hub). Luật Firestore chặn mọi truy cập từ client; chỉ máy chủ dùng tài khoản dịch vụ, quyền do IAM quyết định.
- Hai tài khoản dịch vụ quyền tối thiểu: `tbt-hub-writer` (roles/datastore.user) chỉ service `datastore` ở Hub giữ; `tbt-region-reader` (roles/datastore.viewer) cho `sync_worker` khu vực.
- Ghi: `sync_worker` mỗi phút so dấu băm từng dòng của 37 bảng, gửi dòng đổi/xóa lên `POST /internal/ingest` của Hub với token riêng từng nước; Hub suy ra nước nguồn từ token, không tin trường trong body.
- Mã hóa ở Hub trước khi rời hệ thống: trường cá nhân (danh mục trong `tbt_common/datastore/catalog.dart`) mã hóa AES-256-GCM theo khóa riêng từng nước, phần dữ liệu đi kèm (AAD) là nước/bảng/mã/trường nên bản mã không chép sang chỗ khác được. Mã tài liệu là HMAC của khóa chính; mỗi dòng có chữ ký HMAC.
- Đọc: `sync_worker` mỗi 10 phút đọc mục lục `regions/{nước}`, chỉ truy vấn bảng vừa đổi, kiểm chữ ký, giải mã dòng của nước mình, lưu vào `mirror_db` tại khu vực; dòng nước khác chỉ có trường thường. Đối chiếu dòng của nước mình với dữ liệu gốc để báo lệch.
- Gom dòng vào tối đa 16 ngăn mỗi bảng, ghi bằng `updateMask` để vừa hạn mức miễn phí (khoảng 20.000 lượt ghi, 50.000 lượt đọc mỗi ngày).

## Hệ quả
- Đã chạy thật VN, DE, US: 11.882 dòng lên kho tổng, đọc về lệch 0, bị sửa 0; VN đọc được tên nhân viên VN, nhân viên DE/US chỉ là bản mã.
- Khóa mã hóa nằm trong `deploy/secrets/` (Hub có cả 6, mỗi khu vực chỉ có của mình); mất khóa thì không đọc lại được dữ liệu cá nhân trên kho tổng. Đổi khóa cần mã hóa lại và chưa tự động.
- CSDL nghiệp vụ ở khu vực vẫn là nguồn chính; kho tổng là bản sao bảo mật, chậm tối đa khoảng 1 phút (ghi) và 10 phút (đọc).
- Dữ liệu cá nhân vẫn rời khỏi nước sở tại ở dạng mã hóa; giải thích với thầy: theo GDPR dữ liệu mã hóa mạnh mà bên lưu trữ không có khóa vẫn được coi là biện pháp bảo vệ, nhưng cần đánh giá pháp lý riêng (Cần kiểm tra).

Yêu cầu liên quan: R03, R14, R46, R98.
