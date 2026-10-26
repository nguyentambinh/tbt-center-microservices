/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Nhân viên đề xuất sửa thông tin cá nhân, HR duyệt thì mới ghi vào hồ sơ
create table if not exists employee_change_requests (
  id           bigserial primary key,
  employee_id  text not null references employees(id),
  changes      jsonb not null,
  reason       text,
  status       text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  requested_at timestamptz not null default now(),
  decided_by   text,
  decided_at   timestamptz,
  note         text
);

create index if not exists employee_change_requests_pending on employee_change_requests (status, requested_at);
-- Mỗi người chỉ có một đề xuất đang chờ
create unique index if not exists employee_change_requests_one_pending on employee_change_requests (employee_id) where status = 'pending';
