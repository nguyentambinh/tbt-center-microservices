/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Báo cáo gửi cấp trên: ảnh chụp số liệu lúc gửi, cấp trên xác nhận hoặc trả lại
create table if not exists report_submissions (
  id            bigserial primary key,
  kind          text not null,
  period        text not null,
  note          text,
  data          jsonb not null,
  status        text not null default 'submitted' check (status in ('submitted', 'acknowledged', 'returned')),
  submitted_by  text not null,
  reviewed_by   text,
  review_note   text,
  created_at    timestamptz not null default now(),
  reviewed_at   timestamptz
);
create index if not exists report_submissions_kind on report_submissions (kind, created_at desc);
