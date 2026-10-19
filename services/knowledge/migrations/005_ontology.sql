/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

-- Bản thể học: lớp có lớp cha, quan hệ có miền, phạm vi và tính chất (xuất được RDF/OWL)
create table if not exists kg_classes (
  id         text primary key,
  parent     text references kg_classes(id),
  labels     jsonb not null,
  summaries  jsonb not null default '{}'
);

alter table kg_relations
  add column if not exists summaries        jsonb not null default '{}',
  add column if not exists domain           text[] not null default '{thing}',
  add column if not exists range            text[] not null default '{thing}',
  add column if not exists is_transitive    boolean not null default false,
  add column if not exists is_symmetric     boolean not null default false,
  add column if not exists inverse_of       text,
  add column if not exists sub_property_of  text,
  -- Quan hệ chỉ do suy luận sinh ra, không ghi trực tiếp
  add column if not exists derived          boolean not null default false;

-- type giữ làm loại hiển thị cho app, class_id là lớp trong bản thể học
alter table kg_nodes drop constraint if exists kg_nodes_type_check;
alter table kg_nodes
  add column if not exists class_id  text references kg_classes(id),
  add column if not exists origin    text not null default 'curated';
alter table kg_nodes drop constraint if exists kg_nodes_origin_check;
alter table kg_nodes add constraint kg_nodes_origin_check check (origin in ('curated', 'extracted'));

-- Cạnh: người soạn, AI trích xuất (đã duyệt) hoặc máy suy luận (kèm luật và các cạnh làm tiền đề)
alter table kg_edges
  add column if not exists origin      text not null default 'curated',
  add column if not exists rule_id     text,
  add column if not exists premises    jsonb,
  add column if not exists evidence    text,
  add column if not exists article_id  text,
  add column if not exists created_at  timestamptz not null default now();
alter table kg_edges drop constraint if exists kg_edges_origin_check;
alter table kg_edges add constraint kg_edges_origin_check
  check (origin in ('curated', 'extracted', 'inferred'));
create index if not exists kg_edges_origin_idx on kg_edges (origin);

-- Luật suy luận; second có dấu ^ là đi ngược cạnh
create table if not exists kg_rules (
  id       text primary key,
  ordinal  integer not null,
  kind     text not null check (kind in ('transitive', 'symmetric', 'inverse', 'subproperty', 'chain')),
  first    text not null references kg_relations(id),
  second   text,
  result   text not null references kg_relations(id),
  -- Cạnh suy ra có hiện trên hình và trong ngữ cảnh cho AI không
  visible  boolean not null default true,
  labels   jsonb not null
);

-- Đề xuất AI trích từ bài viết, chờ HR duyệt (R51)
create table if not exists kg_proposals (
  id           uuid primary key default gen_random_uuid(),
  batch        uuid not null,
  article_id   text not null,
  lang         text not null,
  kind         text not null check (kind in ('node', 'edge')),
  payload      jsonb not null,
  evidence     text,
  confidence   real,
  status       text not null default 'pending'
                 check (status in ('pending', 'approved', 'rejected', 'invalid')),
  reason       text,
  provider     text not null,
  model        text,
  created_at   timestamptz not null default now(),
  reviewed_by  text,
  reviewed_at  timestamptz
);
create index if not exists kg_proposals_status_idx on kg_proposals (status, created_at);

-- Bài nào đã cho AI đọc với nội dung nào; nội dung đổi thì đọc lại
create table if not exists kg_extractions (
  article_id    text not null,
  lang          text not null,
  content_hash  text not null,
  provider      text not null,
  model         text,
  proposals     integer not null,
  extracted_at  timestamptz not null default now(),
  primary key (article_id, lang)
);
