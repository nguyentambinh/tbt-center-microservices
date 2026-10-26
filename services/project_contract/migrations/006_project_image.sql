/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

-- Ảnh dự án: đường dẫn object trong bucket tbt-media của Garage khu vực (projects/<mã>.jpg)
alter table projects add column if not exists image_key text;
