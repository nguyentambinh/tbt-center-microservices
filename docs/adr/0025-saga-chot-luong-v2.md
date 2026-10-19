# ADR 0025: Saga chốt lương v2: đủ ba loại bước, khóa ngữ nghĩa, xử lý pivot không rõ kết quả

Ngày: 2026-10-16. Trạng thái: đã áp dụng (mở rộng ADR 0009).

## Bối cảnh
Saga v1 (ADR 0009) có hai bước đầu chỉ đọc, nên "bù trừ" thực chất chỉ là hủy phiếu nháp. Saga còn thiếu cách ly (isolation): đang chốt kỳ 10 mà HR duyệt thêm đơn tăng ca kỳ 10 thì số liệu lệch. Đợt bị treo hoặc bù trừ lỗi thì chưa có cách xử lý rõ ràng.

## Quyết định
- Đủ ba loại bước theo cách gọi của Microsoft Azure Architecture Center (mẫu Saga):
  - bù trừ được (compensable): `lock_period` (attendance khóa kỳ, bù trừ: mở khóa), `calculate` (phiếu nháp, bù trừ: hủy), `reserve_budget` (finance giữ ngân sách lương, bù trừ: nhả);
  - pivot: `pay` (ngân hàng chuyển tiền, không lấy lại được);
  - thử lại được (retryable): `record_expense` (ghi chi phí lương sang finance), `issue_payslips` (sự kiện `PayslipIssued` từng người, notification gửi đẩy), `unlock_period`.
- Khóa ngữ nghĩa (semantic lock): bảng `period_locks` ở attendance; duyệt đơn nghỉ, tăng ca của kỳ đang khóa trả 409 `period_locked`. Kiểm khóa nằm trong giao dịch duyệt đơn, cộng advisory lock của Postgres (duyệt đơn: khóa chung; khóa kỳ: khóa riêng) nên không có kẽ hở giữa lúc khóa và lúc đọc giờ công.
- Mỗi bước có hạn chót. Chạy lại thì bỏ qua bước đã xong (tính từ lần bấm chạy lại gần nhất). Watchdog mỗi phút tìm đợt `running` quá 10 phút không có bước mới, tự chạy tiếp; quá 3 lần thì `needs_attention`.
- Bước sau pivot và bước bù trừ thử lại có giãn cách (1, 2, 4, 8, 16 giây); hết lượt thì `needs_attention` kèm sự kiện `PayrollRunNeedsAttention` báo cho tài chính. Không im lặng bỏ qua.
- **Pivot không rõ kết quả** (quá hạn, mất kết nối) không được bù trừ: Saga chi lại với cùng mã tham chiếu (ngân hàng chống chuyển trùng) để đối soát; hết lượt thì `needs_attention`. Chỉ bù trừ khi ngân hàng trả lời rõ là từ chối.
- Sự kiện `PayslipIssued` lên sổ audit ở Hub chỉ mang kỳ và mã nhân viên, không mang số lương (dữ liệu cá nhân ở nước sở tại).

## Hệ quả
- Đã thử thật: US chạy trơn tru 10 bước; DE ngân hàng lỗi thì nhả ngân sách, mở khóa, chạy lại hoàn tất; VN đang chốt thì HR duyệt đơn bị chặn `period_locked`, chốt xong duyệt được.
- Tìm ra lỗi thật khi thử ngân hàng chậm: v2 bản đầu coi quá hạn ở bước chi là lỗi và bù trừ, trong khi ngân hàng đã chuyển 65 khoản. Sau khi sửa, chạy lại đợt đó ghi nhận đủ 65 khoản, ngân hàng vẫn 65 giao dịch.
- Test Saga 17 ca (trơn tru, lỗi trước pivot, chi một phần, vượt ngân sách, sau pivot lỗi tạm thời và lỗi mãi, bù trừ lỗi, quá hạn, chạy tiếp, pivot không rõ kết quả).
- Thêm ba service tham gia Saga (attendance, finance, notification), nên lỗi một service sẽ kéo dài đợt chốt; đổi lại số liệu nhất quán hơn.

Yêu cầu liên quan: R04, R30, R73, R97.
