# ADR 0031: Chuyển lương theo tập đoàn, công ty, từng người; chống chuyển trùng và nhật ký chuyển

Ngày: 2026-10-19. Trạng thái: đã áp dụng. Nối tiếp ADR 0025.

## Bối cảnh
Saga chốt lương (ADR 0025) tính và chi cho cả một khu vực trong một lượt. Thực tế còn cần chuyển cho một vài người (người mới vào, người bị lỗi tài khoản), chuyển cho cả tập đoàn trong một thao tác, và phải tránh chi hai lần cho cùng một người trong một kỳ. Kênh chi thật (payOS) chuyển từng khoản khoảng 0,5–1 giây, nên một công ty 65 người mất cả phút, vượt hạn chờ của app (15 giây) và giữa hai service (20 giây).

## Quyết định
- **Ba cách chuyển trên cùng một màn hình:**
  - Cả tập đoàn: app gọi song song service payroll của từng khu vực.
  - Từng công ty: kỳ chưa chốt thì chạy Saga; đợt lỗi thì chạy lại phần chưa chi; đã chốt thì đi qua `/payouts`.
  - Từng người: chọn một hoặc nhiều người rồi gửi `employeeIds`.
- **`POST /payroll/payouts`** (`PayoutDesk`) với `duplicates = ask | skip | resend`:
  - `ask`: có người đã nhận thì trả 409 `already_paid` kèm danh sách, chưa chuyển cho ai. App hiện cảnh báo, người dùng chọn Bỏ qua người đã nhận hoặc Chuyển lại.
  - `skip`: chỉ chuyển người chưa nhận, người đã nhận ghi `skipped`.
  - `resend`: chuyển thêm cho người đã nhận. Mỗi lần chuyển lại có mã mới `PAY-<kỳ>-<mã NV>-R<n>`, vì kênh chi coi cùng mã là cùng một lệnh (khóa chống trùng).
- **Chuyển ở nền từng khoản:** route trả 202 ngay; mỗi khoản một lời gọi tới kênh chi, xong khoản nào ghi nhật ký khoản đó. Quá hạn thì gửi lại đúng mã tham chiếu để đối soát (payOS báo 606 "đã tồn tại" thì tra lệnh cũ theo `referenceId`, không chi lần hai); vẫn không rõ thì ghi `in_doubt`. payOS báo 429 thì chờ 2/4/8 giây rồi gửi lại. Kênh chi từ chối thì dừng, các khoản còn lại ghi `failed` kèm lý do. Mỗi kỳ chỉ có một lượt chuyển chạy tại một thời điểm.
- **Nhật ký `payout_log` chỉ ghi thêm** (trigger chặn sửa, xóa): mỗi lần chuyển, chuyển lại, bỏ qua, cảnh báo trùng, chuyển lỗi là một dòng, có người làm, mã tham chiếu, mã giao dịch phía kênh chi, số tiền và lý do. Saga cũng ghi vào đây khi chi. Mỗi dòng phát thêm sự kiện `PayoutLogged` (không mang số tiền) qua Outbox lên sổ audit ở Hub. App có tab Nhật ký.
- **Quyền:** tài chính chỉ thao tác trong khu vực của mình. Ban điều hành (`executive`) gọi được `payroll-runs` và `payouts` của mọi khu vực (`anyRegionRoles` trong `requireClaims`), nhưng khi xem công ty khác thì số tiền từng người bị ẩn (R26).
- **Kênh chi riêng từng công ty:** `integration` của mỗi khu vực đọc `deploy/secrets/payos-<khu vực>.env`. Không có file hoặc chưa bật thì chi qua `bank_mock`.

## Hệ quả
- Chuyển trùng phải có người chọn rõ, và lựa chọn nào cũng để lại dấu vết.
- App không bị treo khi chi nhiều khoản; tiến độ xem ở tab Nhật ký (tự tải lại mỗi 3 giây trong 3 phút). Một khoản qua payOS mất 6–8 giây.
- Khoản chuyển lại chưa ghi thêm chi phí sang finance; số tiền chuyển lại chỉ nằm trong `payout_log`.
- Kênh chi hộ payOS chỉ chuyển tới tài khoản ngân hàng hợp lệ (đích là ví điện tử bị từ chối với mã 607) và chỉ nhận lệnh từ IP đã khai báo.
