# ADR 0016: Sao lưu bằng pg_dump theo từng database, kèm SHA-256, khôi phục thử trước

Ngày: 2026-10-15. Trạng thái: đã áp dụng.

## Bối cảnh
Cách đầy đủ là pgBackRest sao lưu đầy đủ định kỳ cùng lưu trữ WAL, khôi phục về một thời điểm, lưu trên S3 đa vùng (R44). Replica không thay được bản sao lưu: xóa nhầm trên primary thì replica cũng xóa theo. Dự án chạy Docker Compose trên một máy, chưa có S3 đa vùng và chưa cấu hình lưu WAL.

## Quyết định
- `deploy/scripts/backup.sh <khu vực|hub>` chạy `pg_dump -Fc` cho từng database của khu vực (Database-per-service) từ primary, ghi vào `deploy/backups/<khu vực>/<thời điểm>/` kèm `SHA256SUMS`. Thư mục này không đưa lên git.
- `deploy/scripts/restore.sh <khu vực> <thời điểm> <database>`: kiểm SHA-256 trước, mã sai thì dừng. Mặc định khôi phục vào database thử `<db>_restore_check` rồi in số dòng từng bảng cạnh database đang chạy để so; `--replace` mới ghi đè database thật; `--drop-check` xóa database thử.
- Mỗi khu vực sao lưu riêng, bản sao lưu của khu vực nào giữ ở khu vực đó (đúng tinh thần lưu dữ liệu tại chỗ, R57, R65).

## Hệ quả
- Đã thử: sao lưu VN (8 database), DE, Hub; khôi phục `payroll_db` vào database thử khớp số dòng mọi bảng (325 phiếu lương, 65 mức lương…); sửa 1 byte trong bản sao lưu thì script báo `FAILED` và không khôi phục.
- Chỉ khôi phục về đúng lúc sao lưu, chưa khôi phục được về một thời điểm bất kỳ (cần lưu WAL, pgBackRest).
- Chưa tự chạy theo lịch, chưa chép sang nơi khác (ổ khác, S3 vùng khác). CV trong Garage chưa có bản sao lưu.

Yêu cầu liên quan: R44, R57, R65.
