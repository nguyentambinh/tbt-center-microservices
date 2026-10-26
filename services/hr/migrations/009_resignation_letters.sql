/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Đơn thôi việc kèm bản đơn (ảnh, Word, PDF) trong Garage và phân tích của AI
alter table resignations add column if not exists letter_key text;
alter table resignations add column if not exists letter_name text;
alter table resignations add column if not exists letter_mime text;
alter table resignations add column if not exists ai_analysis jsonb;
alter table resignations add column if not exists ai_source text;
