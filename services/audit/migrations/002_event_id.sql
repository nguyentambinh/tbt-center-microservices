/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Chống trùng theo mã sự kiện do khu vực sinh ra. Dòng cũ chưa có mã thì để trống.
alter table events add column if not exists event_id uuid;
create unique index if not exists events_event_id_idx on events (event_id);
alter table events drop constraint if exists events_region_source_service_outbox_id_key;
