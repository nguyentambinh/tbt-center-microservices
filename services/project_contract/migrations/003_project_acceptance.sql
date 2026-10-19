/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Trạng thái dự án và lần nghiệm thu (R100): nghiệm thu thì ghi doanh thu ở finance.
alter table projects add column if not exists status text not null default 'in_progress';
alter table projects add column if not exists accepted_on date;
alter table projects add column if not exists accepted_by text;
