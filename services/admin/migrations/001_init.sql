/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Thao tác quản trị (SQL, sao lưu, đổi tài khoản) ghi qua outbox để lên sổ kiểm toán ở Hub
create table if not exists outbox (
  id            bigserial primary key,
  aggregate     text not null,
  aggregate_id  text not null,
  event_type    text not null,
  payload       jsonb not null,
  created_at    timestamptz not null default now(),
  published_at  timestamptz,
  event_id      uuid not null default gen_random_uuid()
);
create index if not exists outbox_pending_idx on outbox (id) where published_at is null;
create unique index if not exists outbox_event_id_idx on outbox (event_id);
