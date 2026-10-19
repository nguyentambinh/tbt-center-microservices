/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Ai đã xem, kiểm tra, xuất sổ kiểm toán, lúc nào, với điều kiện gì (R90).
-- Cũng chỉ ghi thêm như bảng events.
create table if not exists access_log (
  id          bigserial primary key,
  user_sub    text not null,
  username    text not null,
  roles       text[] not null,
  action      text not null,
  filters     jsonb not null default '{}',
  row_count   int,
  checksum    char(64),
  accessed_at timestamptz not null default now()
);

drop trigger if exists access_log_no_update on access_log;
create trigger access_log_no_update before update or delete on access_log
  for each row execute function events_append_only();
