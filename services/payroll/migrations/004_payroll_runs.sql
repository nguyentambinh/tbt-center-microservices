/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Mỗi kỳ lương có đúng một đợt chốt (Saga). Chạy lại đợt lỗi thì dùng lại đợt cũ.
create table if not exists payroll_runs (
  id          uuid primary key default gen_random_uuid(),
  period      char(7) not null unique,
  status      text not null default 'running',
  started_by  text not null,
  error       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Nhật ký từng bước của Saga: để xem lại đợt chốt đã đi tới đâu, lỗi ở đâu.
create table if not exists payroll_run_steps (
  id      bigserial primary key,
  run_id  uuid not null references payroll_runs(id),
  step    text not null,
  status  text not null,
  detail  text,
  at      timestamptz not null default now()
);

-- Phiếu lương do đợt chốt tạo: 'draft' khi mới tính, 'paid' khi ngân hàng đã chuyển.
alter table payslips add column if not exists status text not null default 'paid';
alter table payslips add column if not exists run_id uuid references payroll_runs(id);
alter table payslips add column if not exists bank_reference text;
