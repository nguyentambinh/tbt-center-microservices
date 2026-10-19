/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- employee_id trỏ sang hr nhưng khác database nên không đặt khóa ngoại.

create table if not exists holidays (
  country_code  char(2) not null,
  holiday_date  date not null,
  name          text not null,
  primary key (country_code, holiday_date)
);

create table if not exists work_schedules (
  employee_id     text not null,
  work_date       date not null,
  is_sunday       boolean not null default false,
  is_holiday      boolean not null default false,
  pay_coefficient numeric(4, 2) not null default 1,
  note            text,
  primary key (employee_id, work_date)
);

create table if not exists timesheets (
  employee_id     text not null,
  work_date       date not null,
  check_in        time,
  check_out       time,
  work_hours      numeric(4, 2),
  overtime_hours  numeric(4, 2),
  total_hours     numeric(4, 2),
  primary key (employee_id, work_date)
);

create table if not exists leave_requests (
  id           uuid primary key default gen_random_uuid(),
  employee_id  text not null,
  from_date    date not null,
  to_date      date not null,
  leave_type   text not null,
  reason       text,
  status       text not null default 'pending',
  approved_by  text,
  created_at   timestamptz not null default now()
);

create table if not exists outbox (
  id            bigserial primary key,
  aggregate     text not null,
  aggregate_id  text not null,
  event_type    text not null,
  payload       jsonb not null,
  created_at    timestamptz not null default now(),
  published_at  timestamptz
);
create index if not exists outbox_pending_idx on outbox (id) where published_at is null;
