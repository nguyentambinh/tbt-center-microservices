/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Vị trí tuyển dụng do HR mở, kèm số người cần tuyển
create table if not exists job_positions (
  id            bigserial primary key,
  title         text not null,
  department    text,
  description   text not null default '',
  requirements  text not null default '',
  headcount     int not null check (headcount > 0),
  status        text not null default 'open' check (status in ('open', 'closed')),
  created_by    text not null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create unique index if not exists job_positions_open_title on job_positions (lower(title)) where status = 'open';

-- Ứng viên chọn một hoặc nhiều vị trí; AI chấm mức phù hợp của CV với từng vị trí
create table if not exists candidate_positions (
  candidate_id   uuid not null references candidates(id),
  position_id    bigint not null references job_positions(id),
  match_score    int check (match_score between 0 and 100),
  match_verdict  text,
  match_strengths text,
  match_gaps     text,
  matched_at     timestamptz,
  created_at     timestamptz not null default now(),
  primary key (candidate_id, position_id)
);
create index if not exists candidate_positions_position on candidate_positions (position_id);

alter table candidates add column if not exists hired_position_id bigint references job_positions(id);
