/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Tiền giao dịch lưu bất biến: số gốc, tiền tệ gốc, tỷ giá áp dụng, ngày tỷ giá, số quy về USD.

create table if not exists salaries (
  employee_id      text primary key,
  employment_type  text not null,
  base_salary      numeric(18, 2) not null,
  currency         char(3) not null
);

create table if not exists coefficients (
  id           text primary key,
  coefficient  numeric(4, 2) not null,
  reason       text not null
);

create table if not exists bonuses_penalties (
  employee_id        text not null,
  occurred_on        date not null,
  kind               text not null,
  amount_original    numeric(18, 2) not null,
  currency_original  char(3) not null,
  coefficient        numeric(4, 2) not null default 1,
  total_original     numeric(18, 2) not null,
  rate_applied       numeric(18, 8) not null,
  rate_date          date not null,
  amount_base        numeric(18, 2) not null,
  primary key (employee_id, occurred_on)
);

create table if not exists payslips (
  id                 uuid primary key default gen_random_uuid(),
  employee_id        text not null,
  period             char(7) not null,
  gross_original     numeric(18, 2) not null,
  net_original       numeric(18, 2) not null,
  currency_original  char(3) not null,
  rate_applied       numeric(18, 8) not null,
  rate_date          date not null,
  amount_base        numeric(18, 2) not null,
  paid_on            date,
  unique (employee_id, period)
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
