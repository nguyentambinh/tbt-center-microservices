/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Mã riêng cho từng sự kiện: Hub chống trùng theo mã này, không theo id tự tăng
-- (id tự tăng đánh lại từ 1 khi nạp lại database).
alter table outbox add column if not exists event_id uuid not null default gen_random_uuid();
create unique index if not exists outbox_event_id_idx on outbox (event_id);
