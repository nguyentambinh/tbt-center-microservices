/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Bước "đã phỏng vấn" (có biên bản) thay cho "offered"
update candidates set status = 'interviewed' where status = 'offered';
update candidate_status_history set status = 'interviewed' where status = 'offered';

-- Lịch phỏng vấn: mỗi ứng viên một lịch, hai bên đề xuất giờ qua lại tới khi xác nhận
create table if not exists interviews (
  candidate_id         uuid primary key references candidates(id),
  scheduled_at         timestamptz not null,
  location             text,
  note                 text,
  state                text not null check (state in ('awaiting_candidate', 'awaiting_hr', 'confirmed', 'cancelled')),
  proposed_by          text not null check (proposed_by in ('hr', 'candidate')),
  minutes_key          text,
  minutes_name         text,
  minutes_uploaded_at  timestamptz,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create table if not exists interview_events (
  id            bigserial primary key,
  candidate_id  uuid not null references candidates(id),
  action        text not null,
  scheduled_at  timestamptz,
  note          text,
  actor         text not null,
  at            timestamptz not null default now()
);
create index if not exists interview_events_candidate on interview_events (candidate_id, at);

-- Email chờ gửi: ghi cùng giao dịch với nghiệp vụ, bộ gửi chạy nền gửi qua SMTP
create table if not exists email_queue (
  id          bigserial primary key,
  recipient   text not null,
  subject     text not null,
  body        text not null,
  status      text not null default 'pending' check (status in ('pending', 'sent', 'failed')),
  attempts    int not null default 0,
  last_error  text,
  created_at  timestamptz not null default now(),
  sent_at     timestamptz
);
create index if not exists email_queue_pending on email_queue (id) where status = 'pending';

-- Thỏa thuận lúc nhận việc
alter table candidates add column if not exists offer_department_id text;
alter table candidates add column if not exists offer_salary numeric(18, 2);
alter table candidates add column if not exists offer_currency char(3);
