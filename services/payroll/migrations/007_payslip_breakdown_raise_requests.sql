/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Phiếu lương chi tiết: lương cơ bản, tăng ca, thưởng phạt, bảo hiểm, thuế (tiền tệ gốc)
alter table payslips add column if not exists base_original numeric(18, 2);
alter table payslips add column if not exists overtime_original numeric(18, 2);
alter table payslips add column if not exists bonus_original numeric(18, 2);
alter table payslips add column if not exists insurance_original numeric(18, 2);
alter table payslips add column if not exists tax_original numeric(18, 2);

-- Đề xuất tăng lương: nhân viên gửi, HR chuyển lên, quản trị khu vực hoặc Ban
-- điều hành duyệt; sửa qua lại chỉ được giữ hoặc tăng mức đề xuất
create table if not exists raise_requests (
  id              bigserial primary key,
  employee_id     text not null,
  current_salary  numeric(18, 2) not null,
  currency        char(3) not null,
  requested       numeric(18, 2) not null check (requested > current_salary),
  proposed        numeric(18, 2) not null check (proposed >= requested),
  reason          text not null,
  status          text not null default 'awaiting_hr' check (status in ('awaiting_hr', 'awaiting_approver', 'awaiting_employee', 'approved', 'rejected', 'withdrawn')),
  decided_by      text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create unique index if not exists raise_requests_one_open on raise_requests (employee_id) where status in ('awaiting_hr', 'awaiting_approver', 'awaiting_employee');

create table if not exists raise_request_events (
  id          bigserial primary key,
  request_id  bigint not null references raise_requests(id),
  action      text not null,
  actor       text not null,
  amount      numeric(18, 2),
  note        text,
  at          timestamptz not null default now()
);
