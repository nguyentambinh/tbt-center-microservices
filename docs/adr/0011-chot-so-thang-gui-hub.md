# ADR 0011: Chốt sổ tài chính theo tháng, chỉ số tổng lên Hub

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
CQRS cần "snapshot theo kỳ" để báo cáo công bố không đổi khi số liệu gốc được sửa về sau (R62). Chứng từ tài chính chi tiết (mua vật liệu, trả nhà cung cấp, doanh thu từng dự án) phải ở lại khu vực, trong khi báo cáo tập đoàn cần doanh thu, chi phí của mọi khu vực.

## Quyết định
- Service `finance` ở mỗi khu vực có thao tác **chốt sổ tháng** (`POST /periods/{YYYY-MM}/close`), chỉ áp dụng cho tháng đã kết thúc, chỉ finance và admin được làm.
- Lúc chốt, tổng doanh thu và chi phí của tháng (tiền khu vực và quy USD) được ghi vào bảng `period_closings` và sự kiện `FinancePeriodClosed` vào Outbox **trong cùng một giao dịch**.
- Mỗi tháng chỉ chốt một lần (khóa chính là kỳ). Đã chốt thì không ghi thêm chứng từ có ngày thuộc tháng đó (409 `period_closed`).
- `report` ở Hub chiếu sự kiện vào bảng `finance_summary` của Doris (UNIQUE KEY theo khu vực và kỳ).
- Mỗi chứng từ mới lưu tỷ giá của chính ngày phát sinh, lấy từ `currency`, không tính lại theo tỷ giá mới.

## Hệ quả
- Hub chỉ nhận số tổng của tháng, không nhận chứng từ hay thông tin nhà cung cấp chi tiết.
- Báo cáo tập đoàn chỉ có tháng đã chốt; tháng đang chạy xem ở màn Tài chính của từng khu vực.
- Muốn sửa số đã chốt phải làm bút toán điều chỉnh ở tháng sau (chưa làm).

Yêu cầu liên quan: R19, R20, R21, R22, R24, R60, R62.
