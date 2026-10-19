/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

-- Kho tri thức: mỗi bài một ngôn ngữ, region null là áp dụng cả tập đoàn
create extension if not exists unaccent;

-- unaccent không immutable nên bọc lại để dùng trong cột sinh tự động
create or replace function kb_unaccent(text) returns text
  language sql immutable parallel safe
  as $$ select public.unaccent('public.unaccent'::regdictionary, $1) $$;

create table if not exists articles (
  id          text not null,
  lang        text not null,
  region      char(2),
  category    text not null,
  title       text not null,
  body        text not null,
  source      text,
  updated_at  timestamptz not null default now(),
  search      tsvector generated always as (
    setweight(to_tsvector('simple', kb_unaccent(title)), 'A') ||
    setweight(to_tsvector('simple', kb_unaccent(body)), 'B')
  ) stored,
  primary key (id, lang)
);
create index if not exists articles_search_idx on articles using gin (search);
