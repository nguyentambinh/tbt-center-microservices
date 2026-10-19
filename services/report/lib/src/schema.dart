/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Mô hình đọc (CQRS) ở Doris. Chỉ service report ghi, nguồn duy nhất là sổ
/// sự kiện audit. Bảng UNIQUE KEY: cùng khóa thì dòng mới thay dòng cũ, nên
/// chiếu lại một sự kiện nhiều lần vẫn ra đúng một dòng.
const reportSchema = [
  'create database if not exists tbt_report',
  '''
create table if not exists payroll_cost (
  run_id         varchar(64),
  region         varchar(8),
  period         varchar(7),
  employees      int,
  currency       varchar(3),
  total_net      decimal(20, 2),
  total_net_usd  decimal(20, 2),
  updated_at     datetime
) unique key (run_id)
distributed by hash (run_id) buckets 1
''',
  '''
create table if not exists leave_requests (
  leave_id     varchar(64),
  region       varchar(8),
  employee_id  varchar(32),
  from_date    date,
  days         int,
  leave_type   varchar(64),
  status       varchar(16),
  updated_at   datetime
) unique key (leave_id)
distributed by hash (leave_id) buckets 1
''',
  '''
create table if not exists candidates (
  candidate_id      varchar(64),
  region            varchar(8),
  country_code      varchar(2),
  applied_position  varchar(128),
  status            varchar(16),
  updated_at        datetime
) unique key (candidate_id)
distributed by hash (candidate_id) buckets 1
''',
  '''
create table if not exists finance_summary (
  region       varchar(8),
  period       varchar(7),
  currency     varchar(3),
  revenue      decimal(20, 2),
  revenue_usd  decimal(20, 2),
  cost         decimal(20, 2),
  cost_usd     decimal(20, 2),
  updated_at   datetime
) unique key (region, period)
distributed by hash (region) buckets 1
''',
  '''
create table if not exists work_hours (
  source_id       varchar(96),
  region          varchar(8),
  kind            varchar(16),
  employee_id     varchar(32),
  work_date       date,
  hours           decimal(8, 2),
  overtime_hours  decimal(8, 2),
  updated_at      datetime
) unique key (source_id)
distributed by hash (source_id) buckets 1
''',
  '''
create table if not exists projection_checkpoint (
  name           varchar(32),
  last_event_id  bigint,
  updated_at     datetime
) unique key (name)
distributed by hash (name) buckets 1
''',
];
