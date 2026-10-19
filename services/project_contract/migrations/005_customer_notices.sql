/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Thông báo, xác nhận gửi khách hàng khi hợp đồng đổi trạng thái (R102).
-- Ghi cùng giao dịch với việc đổi trạng thái; liên hệ của khách ở lại khu vực.
-- Chưa có máy chủ email/SMS nên dừng ở trạng thái 'queued'.
create table if not exists customer_notices (
  id           uuid primary key default gen_random_uuid(),
  project_id   text not null references projects(id),
  customer_id  text not null,
  channel      text not null,
  recipient    text not null,
  kind         text not null,
  params       jsonb not null default '{}',
  status       text not null default 'queued',
  created_at   timestamptz not null default now()
);
