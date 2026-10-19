/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

create table if not exists customers (
  id             text primary key,
  country_code   char(2) not null,
  customer_type  text not null,
  name           text not null,
  contact        text,
  address        text
);

create table if not exists contracts (
  id                 text primary key,
  country_code       char(2) not null,
  name               text not null,
  contract_type      text,
  start_date         date,
  expected_end_date  date
);

create table if not exists projects (
  id                          text primary key,
  company_id                  text not null,
  country_code                char(2) not null,
  customer_id                 text references customers(id),
  deposit_amount              numeric(18, 2),
  expected_acceptance_amount  numeric(18, 2),
  currency                    char(3) not null
);

create table if not exists project_contracts (
  id           text primary key,
  project_id   text not null references projects(id),
  contract_id  text not null references contracts(id),
  end_date     date
);

create table if not exists project_members (
  project_contract_id  text references project_contracts(id),
  employee_id          text not null,
  total_hours          numeric(8, 2),
  project_salary       numeric(18, 2),
  primary key (project_contract_id, employee_id)
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
