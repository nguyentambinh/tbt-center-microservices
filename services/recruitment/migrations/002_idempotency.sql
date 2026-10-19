/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

create table if not exists idempotency_keys (
  key         text primary key,
  method      text not null,
  path        text not null,
  status      int,
  body        text,
  created_at  timestamptz not null default now()
);

create index if not exists candidates_status_idx on candidates (status, created_at desc);
