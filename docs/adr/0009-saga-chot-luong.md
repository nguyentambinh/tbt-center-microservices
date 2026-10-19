# ADR 0009: Saga điều phối cho chốt lương

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Chốt lương cần dữ liệu và hành động của nhiều service: giờ công (attendance), tỷ giá (currency), tính lương (payroll), chuyển khoản (integration → ngân hàng). Mỗi service có database riêng nên không dùng được một giao dịch chung; Saga thay cho 2PC.

## Quyết định
Saga kiểu **điều phối (orchestration)**, payroll là bên điều phối:
1. `collect_hours`: lấy giờ tăng ca từ attendance (`/internal/hours`).
2. `fetch_rate`: lấy tỷ giá từ currency (`/internal/rate`) để quy USD.
3. `calculate`: tính và ghi phiếu lương nháp (giao dịch cục bộ).
4. `pay`: chi qua integration → ngân hàng, có Circuit Breaker.
5. `complete`: đánh dấu hoàn tất, phát sự kiện `PayrollRunCompleted` qua Outbox.

Lỗi ở bất kỳ bước nào thì chạy **bù trừ**: hủy phiếu nháp chưa chi, đánh dấu đợt lỗi, phát `PayrollRunFailed`. Khoản ngân hàng đã chuyển thì giữ là đã trả, vì tiền không lấy lại tự động được.

Trạng thái và nhật ký từng bước lưu trong `payroll_runs`, `payroll_run_steps`. Chạy lại đợt lỗi thì đi tiếp; mã tham chiếu chuyển khoản cố định `PAY-{kỳ}-{nhân viên}` nên ngân hàng không chuyển trùng. Service khởi động lại giữa chừng thì tự chạy tiếp các đợt đang dở.

Lời gọi giữa các service đi qua đường `/internal/...` có `X-Internal-Token`; gọi từ ngoài qua Kong bị chặn 401.

## Hệ quả
- Đã thử thật: chốt 65 người ở VN, 40 người ở DE; tắt ngân hàng thì bù trừ đúng, bật lại và chạy lại thì hoàn tất mà không chi trùng.
- Chọn điều phối thay cho kiểu "biên đạo" (choreography) để luồng nằm ở một chỗ, dễ đọc, dễ xem lại khi bảo vệ.

Yêu cầu liên quan: R16, R19, R37, R72, R74.
