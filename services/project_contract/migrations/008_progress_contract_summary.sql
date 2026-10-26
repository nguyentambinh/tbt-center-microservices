/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Phần trăm khối lượng đã làm (do quản lý dự án cập nhật), thay cho tiến độ
-- tính theo thời gian
alter table projects add column if not exists progress_percent int check (progress_percent between 0 and 100);

-- Tóm tắt điều khoản chính của hợp đồng (phạm vi, thanh toán, bảo hành)
alter table contracts add column if not exists summary text;
