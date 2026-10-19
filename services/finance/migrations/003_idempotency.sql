/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Kết quả các request ghi đã xử lý, để gửi lại cùng Idempotency-Key không ghi trùng.
create table if not exists idempotency_keys (
  key         text primary key,
  method      text not null,
  path        text not null,
  status      int,
  body        text,
  created_at  timestamptz not null default now()
);

