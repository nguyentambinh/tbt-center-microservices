/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Đơn xin thôi việc: báo trước ít nhất 30 ngày, HR duyệt, qua ngày cuối thì
-- HR hoàn tất (bảo lưu hồ sơ, rút khỏi dự án)
create table if not exists resignations (
  id           bigserial primary key,
  employee_id  text not null references employees(id),
  last_day     date not null,
  reason       text not null,
  status       text not null default 'pending' check (status in ('pending', 'approved', 'rejected', 'withdrawn', 'completed')),
  decided_by   text,
  note         text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create unique index if not exists resignations_one_open on resignations (employee_id) where status in ('pending', 'approved');
