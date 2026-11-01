/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

-- Vai trò của người gửi lúc tạo đơn: người cùng cấp không duyệt đơn đó
alter table leave_requests add column if not exists requester_roles text;
alter table overtime_requests add column if not exists requester_roles text;
