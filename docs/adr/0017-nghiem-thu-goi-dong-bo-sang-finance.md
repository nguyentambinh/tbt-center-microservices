# ADR 0017: Nghiệm thu dự án gọi đồng bộ sang finance trước khi đổi trạng thái

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
R100 yêu cầu quản lý dự án, hợp đồng để phục vụ tính doanh thu. Khi dự án được nghiệm thu, doanh thu phải xuất hiện ở tài chính của khu vực. Hai việc nằm ở hai service, hai database khác nhau (`project_contract_db`, `finance_db`), nên không có giao dịch chung.

## Quyết định
- `POST /acceptances/{mã dự án}` ở project_contract (chỉ finance, admin, executive), qua Kong là `/project-contract/acceptances/{mã}`.
- Trong một giao dịch của project_contract: khóa dòng dự án (`for update`), **gọi finance trước** (`POST /internal/acceptances`, `X-Internal-Token`), finance trả lời xong mới đổi trạng thái dự án sang `accepted` và ghi `ProjectAccepted` vào Outbox.
- finance ghi `acceptance_revenues` với khóa chính là mã dự án, tỷ giá theo ngày nghiệm thu. Gọi lại không ghi trùng (`on conflict do nothing`); tháng đã chốt sổ thì trả 409 `period_closed`.
- finance lỗi thì giao dịch project_contract rollback, dự án vẫn "đang thi công", app báo `finance_unavailable`; bấm lại lúc khác vẫn an toàn.
- notification báo cho vai trò finance khi có `ProjectAccepted`.
- Đọc lại dự án ngay sau khi ghi thì đọc primary, vì replica có thể chưa kịp chép.

## Vì sao không dùng Saga như chốt lương
Ở đây chỉ có hai bước, và bước ở finance tự chống trùng. Gọi đồng bộ có bên nhận idempotent đơn giản hơn mà vẫn không để lệch dữ liệu. Saga (ADR 0009) dành cho quy trình nhiều bước, có bước không lấy lại được (chuyển tiền).

## Hệ quả
- Đã thử thật ở US: nghiệm thu USDA001, doanh thu tháng 10 tăng đúng 950.000 USD, bấm lại thì 409 `already_accepted`, `finance.us` nhận thông báo.
- Có một ca hiếm: finance đã ghi nhưng project_contract sập trước khi commit. Khi đó dự án vẫn "đang thi công". Bấm nghiệm thu lại thì finance trả `created: false` (không ghi trùng), còn project_contract đổi trạng thái bình thường.
- Kong nhớ IP cũ của container: tạo lại nhiều container cùng lúc thì phải khởi động lại Kong, không thì request bị gửi nhầm sang service khác (đã gặp, báo "Route not found").

Yêu cầu liên quan: R16, R19, R100.
