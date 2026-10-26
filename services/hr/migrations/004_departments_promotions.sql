/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Bảo lưu hồ sơ: không xóa nhân viên, chỉ đổi trạng thái và giữ thông tin cá nhân
alter table employees add column if not exists status text not null default 'active';
alter table employees add column if not exists archived_at timestamptz;
alter table employees add column if not exists archived_reason text;
alter table employees drop constraint if exists employees_status_check;
alter table employees add constraint employees_status_check check (status in ('active', 'archived'));
create index if not exists employees_status_department on employees (status, department_id);

-- Phòng ban đã giải thể: lý do và phòng nhận lại nhân viên
create table if not exists department_dissolutions (
  id             bigserial primary key,
  department_id  text not null,
  name           text not null,
  company_id     text,
  reason_code    text not null check (reason_code in ('no_longer_needed', 'restructured', 'underperforming', 'outsourced', 'business_closed')),
  note           text,
  merged_into    text,
  members_moved  int not null default 0,
  dissolved_by   text,
  dissolved_at   timestamptz not null default now()
);

-- Đề cử thăng chức: HR gửi, Ban lãnh đạo duyệt thì đổi chức vụ và tăng lương
create table if not exists promotion_nominations (
  id                bigserial primary key,
  employee_id       text not null references employees(id),
  nominated_by      text not null,
  current_position  text,
  proposed_position text not null,
  raise_percent     numeric(5, 2) not null check (raise_percent > 0 and raise_percent <= 100),
  reason            text not null,
  status            text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  decided_by        text,
  decided_at        timestamptz,
  note              text,
  created_at        timestamptz not null default now()
);

create unique index if not exists promotion_nominations_one_pending on promotion_nominations (employee_id) where status = 'pending';
