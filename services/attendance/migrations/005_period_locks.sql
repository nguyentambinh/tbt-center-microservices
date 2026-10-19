/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

-- Kỳ đang chốt lương: attendance không duyệt thêm đơn của kỳ này
create table if not exists period_locks (
  period     char(7) primary key,
  run_id     text not null,
  locked_at  timestamptz not null default now()
);
