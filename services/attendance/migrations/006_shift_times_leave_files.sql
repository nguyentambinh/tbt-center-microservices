/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Giờ ca: qua giờ kết thúc ca thì không chấm vào được (ra ca trễ vẫn được)
alter table work_schedules add column if not exists shift_start time not null default '08:00';
alter table work_schedules add column if not exists shift_end time not null default '17:00';

-- Minh chứng đơn nghỉ (Word, PDF, ảnh) trong bucket tbt-media, AI tóm tắt cho HR
create table if not exists leave_attachments (
  id           uuid primary key default gen_random_uuid(),
  leave_id     uuid not null references leave_requests(id),
  mime_type    text not null,
  object_key   text not null,
  file_name    text not null,
  uploaded_at  timestamptz not null default now()
);
create index if not exists leave_attachments_leave on leave_attachments (leave_id, uploaded_at);

alter table leave_requests add column if not exists ai_summary jsonb;
alter table leave_requests add column if not exists ai_source text;
