/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-17
 */

-- Bộ chuyển tiếp sổ audit lên RabbitMQ nhớ đã phát tới sự kiện nào
create table if not exists relay_state (
  name     text primary key,
  last_id  bigint not null
);

-- Lần đầu bật thì phát từ sự kiện mới, không dồn cả sổ cũ lên hàng đợi
insert into relay_state (name, last_id)
select 'rabbitmq', coalesce(max(id), 0) from events
on conflict (name) do nothing;
