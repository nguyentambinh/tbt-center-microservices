/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

-- Saga v2: đếm số lần resume để biết đợt bị kẹt lặp lại
alter table payroll_runs add column if not exists attempts int not null default 0;
