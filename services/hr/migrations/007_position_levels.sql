/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

-- Cấp bậc chức vụ (cây chức vụ): 1 nhân viên, 2 chuyên viên/kỹ sư/giám sát,
-- 3 chỉ huy/phó phòng, 4 trưởng phòng/quản lý, 5 giám đốc khối, 6 Ban lãnh đạo.
-- Thăng chức chỉ được lên chức vụ có cấp cao hơn
alter table positions add column if not exists level int not null default 1 check (level between 1 and 6);

update positions set level = case
  when name ~* '(tổng giám đốc|ceo|geschäftsführ|presidente|chief executive)' then 6
  when name ~* '(giám đốc|director|direktor|diretor)' then 5
  when name ~* '(trưởng phòng|quản lý|văn phòng quản lý|manager|leiter|gerente|head)' then 4
  when name ~* '(chỉ huy|phó phòng|deputy|stellvertret|supervisor|lead|coordenador)' then 3
  when name ~* '(giám sát|kỹ sư|đánh giá|kiểm|engineer|ingenieur|engenheiro|analyst|specialist|spezialist|especialista)' then 2
  else 1
end
where level = 1;

-- Bậc thang chức vụ chuẩn để có chỗ thăng lên, tên theo nước của khu vực
with country as (select coalesce((select country_code from employees limit 1), 'US') as cc)
insert into positions (id, name, salary_coefficient, level)
select v.id, case country.cc when 'VN' then v.vi when 'DE' then v.de when 'BR' then v.pt else v.en end, v.k, v.lv
from country, (values
  ('LV2-SENIOR', 'Chuyên viên chính', 'Senior specialist', 'Senior-Spezialist', 'Especialista sênior', 1.4, 2),
  ('LV3-DEPUTY', 'Phó phòng', 'Deputy head', 'Stellvertretende Leitung', 'Coordenador adjunto', 1.8, 3),
  ('LV4-HEAD', 'Trưởng phòng', 'Head of department', 'Abteilungsleitung', 'Gerente de departamento', 2.3, 4),
  ('LV5-DIRECTOR', 'Giám đốc khối', 'Division director', 'Bereichsdirektor', 'Diretor de área', 3.0, 5),
  ('LV6-EXECUTIVE', 'Ban lãnh đạo', 'Executive board', 'Geschäftsführung', 'Diretoria executiva', 4.0, 6)
) as v(id, vi, en, de, pt, k, lv)
on conflict (id) do nothing;
