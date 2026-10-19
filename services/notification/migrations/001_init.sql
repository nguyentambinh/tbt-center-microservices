/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Người nhận: 'employee:<mã nhân viên>', 'candidate:<mã hồ sơ>' hoặc
-- 'role:<vai trò>' (mọi người có vai trò đó trong khu vực).
-- Nội dung không lưu thành câu: lưu loại + tham số, app dịch theo ngôn ngữ.
create table if not exists notifications (
  id          uuid primary key default gen_random_uuid(),
  event_id    uuid not null,
  recipient   text not null,
  kind        text not null,
  params      jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  -- Đọc lại cùng một sự kiện không sinh thông báo trùng.
  unique (event_id, recipient)
);
create index if not exists notifications_recipient_idx
  on notifications (recipient, created_at desc);

-- Thông báo gửi theo vai trò có nhiều người nhận, nên đã đọc lưu theo từng người.
create table if not exists notification_reads (
  notification_id  uuid not null references notifications(id),
  user_sub         text not null,
  read_at          timestamptz not null default now(),
  primary key (notification_id, user_sub)
);

-- Đã đọc sổ sự kiện ở Hub tới đâu.
create table if not exists consumer_checkpoint (
  name           text primary key,
  last_event_id  bigint not null
);

-- Mã thiết bị để gửi thông báo đẩy (FCM) khi có Firebase.
create table if not exists device_tokens (
  token       text primary key,
  user_sub    text not null,
  platform    text not null default 'android',
  updated_at  timestamptz not null default now()
);
