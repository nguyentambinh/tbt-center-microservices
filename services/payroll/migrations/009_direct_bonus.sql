/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Thưởng phạt văn phòng quản lý ghi thẳng: một người có nhiều khoản trong ngày,
-- mỗi khoản có mã riêng, lý do và người ghi
alter table bonuses_penalties add column if not exists id bigserial;
alter table bonuses_penalties drop constraint if exists bonuses_penalties_pkey;
alter table bonuses_penalties add primary key (id);
alter table bonuses_penalties add column if not exists reason text;
alter table bonuses_penalties add column if not exists created_by text;
alter table bonuses_penalties add column if not exists created_at timestamptz not null default now();
create index if not exists bonuses_penalties_employee_idx on bonuses_penalties (employee_id, occurred_on);
