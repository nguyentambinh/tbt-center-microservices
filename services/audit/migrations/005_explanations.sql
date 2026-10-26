/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- AI giải thích điểm bất thường của một sự kiện: lưu riêng, sổ events vẫn
-- chỉ ghi thêm; mỗi sự kiện giải thích một lần
create table if not exists event_explanations (
  event_id     bigint primary key references events(id),
  explanation  jsonb not null,
  source       text not null,
  created_at   timestamptz not null default now()
);
