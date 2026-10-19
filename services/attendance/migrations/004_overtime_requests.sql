/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Đơn xin tăng ca (R36). Mỗi người mỗi ngày tối đa một đơn chưa bị từ chối.
create table if not exists overtime_requests (
  id           uuid primary key default gen_random_uuid(),
  employee_id  text not null,
  work_date    date not null,
  hours        numeric(4, 2) not null check (hours > 0 and hours <= 12),
  reason       text,
  status       text not null default 'pending',
  decided_by   text,
  created_at   timestamptz not null default now()
);
create unique index if not exists overtime_one_per_day_idx
  on overtime_requests (employee_id, work_date) where status <> 'rejected';
