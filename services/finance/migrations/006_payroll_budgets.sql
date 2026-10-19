/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

-- Ngân sách lương mỗi kỳ do Saga chốt lương giữ chỗ, nhả hoặc ghi chi
create table if not exists payroll_budgets (
  period        char(7) primary key,
  run_id        text not null,
  amount        numeric(20, 2) not null,
  currency      char(3) not null,
  status        text not null default 'reserved',
  spent_amount  numeric(20, 2),
  paid_count    int,
  reserved_at   timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
