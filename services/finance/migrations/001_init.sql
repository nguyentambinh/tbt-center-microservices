/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- project_id, customer_id thuộc project_contract (database khác) nên chỉ lưu mã.

create table if not exists revenue_areas (
  id             text primary key,
  province_name  text not null,
  coefficient    numeric(4, 2) not null
);

create table if not exists revenue_categories (
  id    text primary key,
  name  text not null
);

create table if not exists risks (
  id           text primary key,
  name         text not null,
  coefficient  numeric(4, 2) not null
);

create table if not exists project_revenues (
  project_id          text not null,
  category_id         text not null references revenue_categories(id),
  area_id             text not null references revenue_areas(id),
  risk_id             text references risks(id),
  change_coefficient  numeric(4, 2) not null default 1,
  amount_original     numeric(18, 2) not null,
  currency_original   char(3) not null,
  rate_applied        numeric(18, 8) not null,
  rate_date           date not null,
  amount_base         numeric(18, 2) not null,
  primary key (project_id, category_id, area_id)
);

create table if not exists service_revenues (
  id                 text primary key,
  customer_id        text not null,
  service_type       text not null,
  used_on            date not null,
  expected_price     numeric(18, 2),
  amount_original    numeric(18, 2) not null,
  currency_original  char(3) not null,
  rate_applied       numeric(18, 8) not null,
  rate_date          date not null,
  amount_base        numeric(18, 2) not null
);

create table if not exists suppliers (
  id       text primary key,
  name     text not null,
  contact  text,
  address  text
);

create table if not exists material_imports (
  id                 text primary key,
  supplier_id        text references suppliers(id),
  material_name      text not null,
  imported_on        date not null,
  amount_original    numeric(18, 2) not null,
  currency_original  char(3) not null,
  rate_applied       numeric(18, 8) not null,
  rate_date          date not null,
  amount_base        numeric(18, 2) not null
);

create table if not exists material_shipments (
  id                 text primary key,
  shipped_on         date not null,
  amount_original    numeric(18, 2) not null,
  currency_original  char(3) not null,
  rate_applied       numeric(18, 8) not null,
  rate_date          date not null,
  amount_base        numeric(18, 2) not null
);

create table if not exists project_costs (
  project_id          text not null,
  import_id           text not null references material_imports(id),
  shipment_id         text not null references material_shipments(id),
  change_coefficient  numeric(4, 2) not null default 1,
  amount_original     numeric(18, 2) not null,
  currency_original   char(3) not null,
  rate_applied        numeric(18, 8) not null,
  rate_date           date not null,
  amount_base         numeric(18, 2) not null,
  primary key (project_id, import_id, shipment_id)
);

create table if not exists market_fluctuations (
  observed_on  date primary key,
  coefficient  numeric(4, 2) not null
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
