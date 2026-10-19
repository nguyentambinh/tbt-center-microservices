-- Sinh tự động bởi tools/seed_data/generate.py, khu vực br. Không sửa tay.
begin;
truncate table project_members, project_contracts, projects, contracts, customers, outbox restart identity cascade;

insert into customers (id, country_code, customer_type, name, contact, address) values
  ('BRDN0001', 'BR', 'business', 'Pereira Imóveis Ltda', '+55 31 97563-5077', 'Av. Brasil, 160 – Rio de Janeiro – RJ, 20000-000'),
  ('BRCN0002', 'BR', 'individual', 'Letícia Ferreira', '+55 21 93720-2810', 'Av. Brasil, 164 – Salvador – BA, 40000-000'),
  ('BRCN0003', 'BR', 'individual', 'Rafael Ferreira', '+55 11 92865-8126', 'Av. Brasil, 20 – Belo Horizonte – MG, 30100-000'),
  ('BRDN0004', 'BR', 'business', 'Ferreira Empreendimentos Ltda', '+55 11 99524-8945', 'Rua São João, 220 – São Paulo – SP, 01000-000'),
  ('BRCN0005', 'BR', 'individual', 'Mateus Ferreira', '+55 41 92025-5826', 'Rua das Flores, 4 – Salvador – BA, 40000-000'),
  ('BRCN0006', 'BR', 'individual', 'Beatriz Martins', '+55 11 98823-1193', 'Av. Getúlio Vargas, 134 – Belo Horizonte – MG, 30100-000'),
  ('BRDN0007', 'BR', 'business', 'Santos Empreendimentos Ltda', '+55 21 95636-6345', 'Rua XV de Novembro, 180 – Salvador – BA, 40000-000'),
  ('BRCN0008', 'BR', 'individual', 'Beatriz Alves', '+55 41 96147-8795', 'Rua São João, 64 – Salvador – BA, 40000-000'),
  ('BRCN0009', 'BR', 'individual', 'Bruno Almeida', '+55 31 91065-5721', 'Av. Getúlio Vargas, 152 – Belo Horizonte – MG, 30100-000'),
  ('BRDN0010', 'BR', 'business', 'Souza Incorporadora S.A.', '+55 31 99229-4447', 'Rua XV de Novembro, 240 – Rio de Janeiro – RJ, 20000-000'),
  ('BRCN0011', 'BR', 'individual', 'Letícia Martins', '+55 21 93753-8598', 'Rua da Paz, 119 – Curitiba – PR, 80000-000'),
  ('BRCN0012', 'BR', 'individual', 'Gustavo Silva', '+55 41 93930-9136', 'Rua São João, 112 – Curitiba – PR, 80000-000'),
  ('BRDN0013', 'BR', 'business', 'Barbosa Incorporadora S.A.', '+55 21 92179-1306', 'Rua XV de Novembro, 72 – Salvador – BA, 40000-000'),
  ('BRCN0014', 'BR', 'individual', 'Thiago Lima', '+55 41 93600-2924', 'Rua São João, 28 – Curitiba – PR, 80000-000'),
  ('BRCN0015', 'BR', 'individual', 'Gabriela Costa', '+55 11 94058-8416', 'Rua da Paz, 172 – Salvador – BA, 40000-000');

insert into contracts (id, country_code, name, contract_type, start_date, expected_end_date) values
  ('BRHD001', 'BR', 'Construção de casa residencial', '1', '2024-11-05', '2025-05-15'),
  ('BRHD002', 'BR', 'Construção de mansão', '2', '2024-04-21', '2024-11-07'),
  ('BRHD003', 'BR', 'Edifício comercial', '3', '2026-01-15', '2026-08-25'),
  ('BRHD004', 'BR', 'Galpão logístico', '4', '2026-08-13', '2027-04-01'),
  ('BRHD005', 'BR', 'Obras de ponte e estrada', '1', '2024-01-19', '2025-06-24'),
  ('BRHD006', 'BR', 'Reforma de escola', '2', '2025-01-17', '2025-12-24'),
  ('BRHD007', 'BR', 'Reforma de shopping', '3', '2026-11-28', '2028-02-12'),
  ('BRHD008', 'BR', 'Edifício residencial', '4', '2025-04-13', '2026-01-14'),
  ('BRHD009', 'BR', 'Construção de casa residencial', '1', '2025-01-20', '2025-06-14'),
  ('BRHD010', 'BR', 'Construção de mansão', '2', '2025-03-21', '2025-08-02');

insert into projects (id, company_id, country_code, customer_id, deposit_amount, expected_acceptance_amount, currency) values
  ('BRDA001', 'TBTRIO', 'BR', 'BRDN0007', 196800.00, 656000.00, 'BRL'),
  ('BRDA002', 'TBTBHZ', 'BR', 'BRCN0005', 328200.00, 1094000.00, 'BRL'),
  ('BRDA003', 'TBTBHZ', 'BR', 'BRCN0008', 345000.00, 1150000.00, 'BRL'),
  ('BRDA004', 'TBTBHZ', 'BR', 'BRDN0010', 303600.00, 1012000.00, 'BRL'),
  ('BRDA005', 'TBTSAO', 'BR', 'BRDN0004', 193200.00, 644000.00, 'BRL'),
  ('BRDA006', 'TBTBHZ', 'BR', 'BRDN0010', 48000.00, 160000.00, 'BRL'),
  ('BRDA007', 'TBTBHZ', 'BR', 'BRCN0012', 148200.00, 494000.00, 'BRL'),
  ('BRDA008', 'TBTRIO', 'BR', 'BRDN0007', 357600.00, 1192000.00, 'BRL'),
  ('BRDA009', 'TBTSAO', 'BR', 'BRDN0013', 89400.00, 298000.00, 'BRL'),
  ('BRDA010', 'TBTBHZ', 'BR', 'BRCN0009', 179400.00, 598000.00, 'BRL');

insert into project_contracts (id, project_id, contract_id, end_date) values
  ('BR2024110500', 'BRDA001', 'BRHD001', '2025-05-17'),
  ('BR2024042101', 'BRDA002', 'BRHD002', '2025-04-09'),
  ('BR2026011502', 'BRDA003', 'BRHD003', '2026-12-04'),
  ('BR2026081303', 'BRDA004', 'BRHD004', '2027-07-16'),
  ('BR2024011904', 'BRDA005', 'BRHD005', '2024-08-11'),
  ('BR2025011705', 'BRDA006', 'BRHD006', '2025-07-13'),
  ('BR2026112806', 'BRDA007', 'BRHD007', '2027-10-04'),
  ('BR2025041307', 'BRDA008', 'BRHD008', '2026-01-07'),
  ('BR2025012008', 'BRDA009', 'BRHD009', '2026-01-09'),
  ('BR2025032109', 'BRDA010', 'BRHD010', '2026-09-06');

insert into project_members (project_contract_id, employee_id, total_hours, project_salary) values
  ('BR2024110500', 'GAB81011RIO', 161, 5782.54),
  ('BR2024110500', 'RAF87001SAO', 106, 3587.86),
  ('BR2024110500', 'MAR81037SAO', 133, 5262.98),
  ('BR2024110500', 'LAR90032RIO', 205, 2701.63),
  ('BR2024042101', 'BRU72039BHZ', 84, 4435.22),
  ('BR2024042101', 'PED96012BHZ', 138, 2380.20),
  ('BR2024042101', 'GAB81011RIO', 93, 5626.78),
  ('BR2024042101', 'LUC60014RIO', 155, 5210.04),
  ('BR2026011502', 'JOA86017RIO', 183, 4904.59),
  ('BR2026011502', 'LUC97033BHZ', 196, 3996.35),
  ('BR2026011502', 'BEA65008RIO', 111, 3456.35),
  ('BR2026011502', 'PAT78020RIO', 182, 4074.33),
  ('BR2026081303', 'LUC60014RIO', 128, 5369.20),
  ('BR2026081303', 'BEA78002RIO', 210, 4093.51),
  ('BR2026081303', 'ALI73019SAO', 107, 4648.48),
  ('BR2026081303', 'BRU91036BHZ', 113, 5313.70),
  ('BR2024011904', 'FER81031SAO', 126, 2594.60),
  ('BR2024011904', 'MAT65026RIO', 201, 5670.24),
  ('BR2024011904', 'MAR73009BHZ', 94, 2332.27),
  ('BR2024011904', 'LAR90032RIO', 148, 5061.39),
  ('BR2025011705', 'MAT61018BHZ', 137, 4698.30),
  ('BR2025011705', 'RAF87001SAO', 184, 2434.78),
  ('BR2025011705', 'MAR92023RIO', 81, 4330.35),
  ('BR2025011705', 'MAR80021BHZ', 113, 3773.88),
  ('BR2026112806', 'JOA86017RIO', 206, 5644.77),
  ('BR2026112806', 'FER66010SAO', 171, 4971.88),
  ('BR2026112806', 'RAF87001SAO', 89, 5054.06),
  ('BR2026112806', 'LAR90032RIO', 206, 3191.15),
  ('BR2025041307', 'LAR90022SAO', 112, 4898.38),
  ('BR2025041307', 'BEA78002RIO', 92, 4714.74),
  ('BR2025041307', 'ANA75003BHZ', 207, 5478.98),
  ('BR2025041307', 'FER66010SAO', 204, 4869.23),
  ('BR2025012008', 'ANA75003BHZ', 158, 3077.47),
  ('BR2025012008', 'FER66010SAO', 86, 2098.42),
  ('BR2025012008', 'DIE61034SAO', 146, 3262.94),
  ('BR2025012008', 'MAR73009BHZ', 137, 3824.35),
  ('BR2025032109', 'BEA65008RIO', 128, 3036.95),
  ('BR2025032109', 'MAT61018BHZ', 92, 2986.25),
  ('BR2025032109', 'LAR96005RIO', 80, 2815.55),
  ('BR2025032109', 'ALI73019SAO', 121, 2656.82);

commit;
