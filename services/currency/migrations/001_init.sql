/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

-- Một USD đổi được bao nhiêu đơn vị tiền tệ quote vào ngày rate_date.
create table if not exists exchange_rates (
  rate_date  date not null,
  quote      char(3) not null,
  rate       numeric(18, 8) not null,
  source     text not null,
  primary key (rate_date, quote)
);
