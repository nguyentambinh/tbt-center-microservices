/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Đề xuất dự án mới: bên lập và Ban lãnh đạo sửa qua lại tới khi cùng xác nhận
create table if not exists project_proposals (
  id             bigserial primary key,
  status         text not null default 'awaiting_executive' check (status in ('awaiting_executive', 'awaiting_proposer', 'approved', 'rejected')),
  data           jsonb not null,
  version        int not null default 1,
  contract_key   text,
  contract_name  text,
  image_key      text,
  created_by     text not null,
  decided_by     text,
  project_id     text references projects(id),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
create index if not exists project_proposals_status on project_proposals (status, updated_at desc);

create table if not exists project_proposal_events (
  id           bigserial primary key,
  proposal_id  bigint not null references project_proposals(id),
  action       text not null,
  actor        text not null,
  data         jsonb,
  note         text,
  at           timestamptz not null default now()
);
create index if not exists project_proposal_events_proposal on project_proposal_events (proposal_id, at);

-- Tệp hợp đồng gốc của dự án tạo từ đề xuất
alter table contracts add column if not exists file_key text;
