/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

-- Đồ thị tri thức: nút là khái niệm, quy tắc, bước, vai trò, service, nước, bài viết
create table if not exists kg_relations (
  id      text primary key,
  labels  jsonb not null
);

create table if not exists kg_nodes (
  id          text primary key,
  type        text not null check (type in
                ('concept', 'process', 'step', 'rule', 'role', 'service', 'region', 'document')),
  labels      jsonb not null,
  summaries   jsonb not null default '{}',
  -- Tên gọi khác đã bỏ dấu, chữ thường; dùng để nhận ra khái niệm trong câu hỏi
  aliases     text[] not null default '{}',
  article_id  text
);
create index if not exists kg_nodes_aliases_idx on kg_nodes using gin (aliases);

create table if not exists kg_edges (
  source    text not null references kg_nodes(id) on delete cascade,
  relation  text not null references kg_relations(id),
  target    text not null references kg_nodes(id) on delete cascade,
  note      text,
  primary key (source, relation, target)
);
create index if not exists kg_edges_target_idx on kg_edges (target);

-- Vector của từng bài (tìm theo nghĩa); content_hash đổi thì tính lại
create table if not exists article_embeddings (
  article_id    text not null,
  lang          text not null,
  model         text not null,
  content_hash  text not null,
  embedding     bytea not null,
  updated_at    timestamptz not null default now(),
  primary key (article_id, lang),
  foreign key (article_id, lang) references articles(id, lang) on delete cascade
);

-- Nhật ký hỏi đáp và phản hồi người dùng (R51); xóa sau 90 ngày
create table if not exists qa_log (
  id          uuid primary key,
  asked_at    timestamptz not null default now(),
  username    text not null,
  region      text not null,
  lang        text not null,
  question    text not null,
  answer      text not null,
  answerable  boolean not null,
  provider    text not null,
  model       text,
  sources     text[] not null default '{}',
  entities    text[] not null default '{}',
  cached      boolean not null default false,
  latency_ms  integer not null,
  helpful     boolean,
  comment     text
);
create index if not exists qa_log_asked_idx on qa_log (asked_at);
