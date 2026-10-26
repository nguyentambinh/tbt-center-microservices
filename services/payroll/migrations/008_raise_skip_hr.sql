/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Đề xuất tăng lương của chính nhân viên HR đi thẳng lên Ban lãnh đạo,
-- không qua bước HR (không ai tự chuyển đơn của mình)
alter table raise_requests add column if not exists skip_hr boolean not null default false;
