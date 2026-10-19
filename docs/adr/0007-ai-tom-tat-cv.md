# ADR 0007: Dùng Claude tóm tắt CV ứng viên

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
HR cần đọc nhanh nhiều CV. Gửi CV ra dịch vụ AI bên ngoài là xử lý dữ liệu cá nhân.

## Quyết định
- Ứng viên phải tick đồng ý trên form thì CV mới được gửi cho AI.
- Bộ phân tích chạy nền trong `recruitment` (không bắt ứng viên chờ), gọi Claude Sonnet 5.5 (`claude-sonnet-5-5`, hằng `claudeModel`) qua HTTP với structured output theo JSON schema cố định, viết bằng ngôn ngữ của khu vực.
- AI chỉ tóm tắt những gì CV ghi, không chấm đậu hay rớt, không đánh giá tuổi, giới tính, dân tộc, tôn giáo, hôn nhân. Quyết định vẫn do HR.
- Lỗi tài khoản API (sai key, hết credit) thì tạm dừng 10 phút, không trừ lượt của hồ sơ; lỗi khác thử tối đa 3 lần để không tốn phí vô ích. Lời gọi đi qua Circuit Breaker (ADR 0005).
- API key chỉ nằm ở server (`deploy/secrets/anthropic.env`), không có trong app.

## Hệ quả
App hiện bản tóm tắt kèm dòng nhắc HR đối chiếu với CV gốc.

Yêu cầu liên quan: R96, R98.
