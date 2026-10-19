/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

create table if not exists companies (
  id            text primary key,
  country_code  char(2) not null,
  name          text not null,
  tier          text,
  address       text
);

create table if not exists specialties (
  id    text primary key,
  name  text not null
);

create table if not exists degrees (
  id    text primary key,
  name  text not null
);

create table if not exists skills (
  id    text primary key,
  name  text not null
);

create table if not exists languages (
  id    text primary key,
  name  text not null
);

create table if not exists specialty_degrees (
  specialty_id  text references specialties(id),
  degree_id     text references degrees(id),
  primary key (specialty_id, degree_id)
);

create table if not exists specialty_skills (
  specialty_id  text references specialties(id),
  skill_id      text references skills(id),
  primary key (specialty_id, skill_id)
);

create table if not exists specialty_languages (
  specialty_id  text references specialties(id),
  language_id   text references languages(id),
  primary key (specialty_id, language_id)
);

create table if not exists departments (
  id             text primary key,
  company_id     text not null references companies(id),
  country_code   char(2) not null,
  name           text not null,
  manager_id     text,
  location_code  text
);

create table if not exists positions (
  id                  text primary key,
  name                text not null,
  specialty_id        text references specialties(id),
  salary_coefficient  numeric(4, 2) not null default 1
);

create table if not exists employees (
  id             text primary key,
  company_id     text not null references companies(id),
  country_code   char(2) not null,
  family_name    text not null,
  given_name     text not null,
  birth_year     int,
  gender         smallint,
  department_id  text references departments(id),
  position_id    text references positions(id),
  email          text,
  photo_url      text,
  labor_contract text,
  hired_on       date
);
create index if not exists employees_company_idx on employees (company_id);

create table if not exists relatives (
  employee_id   text references employees(id),
  full_name     text,
  phone         text,
  address       text,
  relationship  text,
  primary key (employee_id, full_name)
);

create table if not exists health_records (
  employee_id      text primary key references employees(id),
  height_cm        int,
  weight_kg        int,
  medical_history  text,
  vision_score     int,
  updated_on       date
);

create table if not exists insurances (
  employee_id       text primary key references employees(id),
  insurance_type    text,
  insurance_number  text,
  expires_on        date
);

create table if not exists contacts (
  employee_id    text primary key references employees(id),
  phone          text,
  address        text,
  facebook       text,
  x_handle       text,
  hometown_code  text
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
