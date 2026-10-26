/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Mã 6 số xác nhận email khi đăng ký; chỉ lưu băm của mã, hết hạn sau 10 phút
create table if not exists signup_codes (
  email        text primary key,
  code_hash    char(64) not null,
  full_name    text not null,
  phone        text not null,
  attempts     int not null default 0,
  expires_at   timestamptz not null,
  last_sent_at timestamptz not null default now()
);

-- HR đã mở xem hồ sơ: ứng viên thấy nhãn "đã được xem" và không sửa được nữa
alter table candidates add column if not exists viewed_at timestamptz;
