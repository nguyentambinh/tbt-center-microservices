/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- FCM: máy nhận thông báo của địa chỉ nào, ngôn ngữ gì
alter table device_tokens add column if not exists recipients text[] not null default '{}';
alter table device_tokens add column if not exists language text not null default 'en';
create index if not exists device_tokens_recipients_idx on device_tokens using gin (recipients);
