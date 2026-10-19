/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

create table if not exists candidates (
  id                uuid primary key default gen_random_uuid(),
  keycloak_sub      text unique,
  country_code      char(2) not null,
  full_name         text not null,
  email             text,
  phone             text,
  applied_position  text,
  status            text not null default 'submitted',
  source            text not null default 'self',
  cv_object_key     text,
  cv_sha256         char(64),
  consent_ai        boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
create unique index if not exists candidates_email_idx on candidates (lower(email)) where email is not null;

-- Tệp nộp bổ sung sau khi đã có hồ sơ: bằng cấp, chứng chỉ, CV bản mới.
create table if not exists candidate_documents (
  id           uuid primary key default gen_random_uuid(),
  candidate_id uuid not null references candidates(id),
  kind         text not null,
  object_key   text not null,
  sha256       char(64) not null,
  uploaded_at  timestamptz not null default now()
);

-- Lịch sử trạng thái để ứng viên xem tiến trình của mình.
create table if not exists candidate_status_history (
  id            bigserial primary key,
  candidate_id  uuid not null references candidates(id),
  status        text not null,
  note          text,
  changed_by    text not null,
  changed_at    timestamptz not null default now()
);

create table if not exists cv_summaries (
  candidate_id  uuid primary key references candidates(id),
  summary       jsonb not null,
  model         text not null,
  created_at    timestamptz not null default now()
);

create table if not exists candidate_imports (
  id           uuid primary key default gen_random_uuid(),
  source_type  text not null,
  source_ref   text,
  imported_by  text not null,
  created_at   timestamptz not null default now()
);

create table if not exists candidate_import_rows (
  id            uuid primary key default gen_random_uuid(),
  import_id     uuid not null references candidate_imports(id),
  row_number    int not null,
  data          jsonb not null,
  action        text not null,
  status        text not null default 'pending',
  error         text,
  candidate_id  uuid references candidates(id)
);

create table if not exists outbox (
  id            bigserial primary key,
  aggregate     text not null,
  aggregate_id  text not null,
  event_type    text not null,
  payload       jsonb not null,
  created_at    timestamptz not null default now(),
  published_at  timestamptz
);
create index if not exists outbox_pending_idx on outbox (id) where published_at is null;
