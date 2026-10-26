/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Đề cử lên cấp tập đoàn: HR, tài chính một nước lên phòng Nhân sự, Tài chính
-- tập đoàn; chỉ văn phòng quản lý tập đoàn duyệt
alter table promotion_nominations add column if not exists scope text not null default 'region';
alter table promotion_nominations drop constraint if exists promotion_nominations_scope_check;
alter table promotion_nominations add constraint promotion_nominations_scope_check check (scope in ('region', 'group'));
alter table promotion_nominations add column if not exists group_role text;
alter table promotion_nominations drop constraint if exists promotion_nominations_group_role_check;
alter table promotion_nominations add constraint promotion_nominations_group_role_check check (group_role is null or group_role in ('hr', 'finance'));

-- Chức vụ cấp tập đoàn (cấp 5), tên theo nước của khu vực
with country as (select coalesce((select country_code from employees limit 1), 'US') as cc)
insert into positions (id, name, salary_coefficient, level)
select v.id, case country.cc when 'VN' then v.vi when 'DE' then v.de when 'BR' then v.pt else v.en end, 3.0, 5
from country, (values
  ('GRP-HR', 'Nhân sự tập đoàn', 'Group HR', 'Konzernpersonal', 'RH do grupo'),
  ('GRP-FIN', 'Tài chính tập đoàn', 'Group finance', 'Konzernfinanzen', 'Finanças do grupo')
) as v(id, vi, en, de, pt)
on conflict (id) do nothing;
