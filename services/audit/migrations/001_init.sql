/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Sổ sự kiện ở Hub: chỉ ghi thêm, mỗi dòng giữ hash của dòng trước (chuỗi băm).
-- Sửa hay xóa một dòng cũ thì từ dòng đó trở đi hash không còn khớp.
create table if not exists events (
  id              bigserial primary key,
  region          text not null,
  source_service  text not null,
  outbox_id       bigint not null,
  aggregate       text not null,
  aggregate_id    text not null,
  event_type      text not null,
  payload         jsonb not null,
  occurred_at     timestamptz not null,
  received_at     timestamptz not null default now(),
  prev_hash       char(64) not null,
  hash            char(64) not null,
  -- Một sự kiện outbox gửi lại nhiều lần cũng chỉ ghi một lần.
  unique (region, source_service, outbox_id)
);

-- Chặn sửa, xóa ở mức database, kể cả khi code service có lỗi.
create or replace function events_append_only() returns trigger as $$
begin
  raise exception 'events is append-only';
end;
$$ language plpgsql;

drop trigger if exists events_no_update on events;
create trigger events_no_update before update or delete on events
  for each row execute function events_append_only();
