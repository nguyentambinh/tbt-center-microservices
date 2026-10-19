/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Trả tiền cho nhà cung cấp, để đối chiếu công nợ (R104).
create table if not exists supplier_payments (
  id                 uuid primary key default gen_random_uuid(),
  supplier_id        text not null references suppliers(id),
  paid_on            date not null,
  amount_original    numeric(18, 2) not null check (amount_original > 0),
  currency_original  char(3) not null,
  rate_applied       numeric(18, 8) not null,
  rate_date          date not null,
  amount_base        numeric(18, 2) not null,
  note               text,
  recorded_by        text not null,
  created_at         timestamptz not null default now()
);
create index if not exists supplier_payments_supplier_idx
  on supplier_payments (supplier_id, paid_on);

-- Số liệu chốt sổ theo tháng (R62). Đã chốt thì không đổi, kể cả khi dữ liệu
-- gốc được nhập thêm về sau; nhập chứng từ vào tháng đã chốt bị chặn.
create table if not exists period_closings (
  period        char(7) primary key,
  currency      char(3) not null,
  revenue       numeric(20, 2) not null,
  revenue_usd   numeric(20, 2) not null,
  cost          numeric(20, 2) not null,
  cost_usd      numeric(20, 2) not null,
  closed_by     text not null,
  closed_at     timestamptz not null default now()
);
