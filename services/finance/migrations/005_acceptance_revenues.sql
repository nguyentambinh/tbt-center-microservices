/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Doanh thu ghi nhận khi dự án được nghiệm thu (project_contract gọi sang).
-- Mỗi dự án nghiệm thu một lần: gọi lại không ghi trùng.
create table if not exists acceptance_revenues (
  project_id         text primary key,
  accepted_on        date not null,
  amount_original    numeric(18, 2) not null check (amount_original >= 0),
  currency_original  char(3) not null,
  rate_applied       numeric(18, 8) not null,
  rate_date          date not null,
  amount_base        numeric(18, 2) not null,
  created_at         timestamptz not null default now()
);
