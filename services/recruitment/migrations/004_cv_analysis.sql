/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Theo dõi lần gọi AI để không gọi lại mãi một CV lỗi (tốn phí).
alter table candidates add column if not exists ai_attempts int not null default 0;
alter table candidates add column if not exists ai_last_error text;
