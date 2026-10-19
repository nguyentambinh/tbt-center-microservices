/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

-- Nhật ký chuyển lương: mỗi lần chuyển, chuyển lại, bỏ qua, cảnh báo trùng là một dòng
create table if not exists payout_log (
  id              bigserial primary key,
  period          char(7) not null,
  employee_id     text not null,
  -- paid | resent | skipped | duplicate_warning | failed | in_doubt
  action          text not null,
  -- saga | manual
  source          text not null,
  reference       text,
  bank_reference  text,
  amount          numeric(18, 2),
  currency        char(3),
  actor           text not null,
  detail          text,
  at              timestamptz not null default now()
);
create index if not exists payout_log_period_idx on payout_log (period, employee_id);

-- Chỉ ghi thêm, không sửa, không xóa
create or replace function payout_log_append_only() returns trigger
language plpgsql as $$
begin
  raise exception 'payout_log is append-only';
end $$;

drop trigger if exists payout_log_no_change on payout_log;
create trigger payout_log_no_change before update or delete on payout_log
  for each row execute function payout_log_append_only();
