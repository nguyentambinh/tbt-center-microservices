-- Sinh tự động bởi tools/seed_data/generate.py, khu vực br. Không sửa tay.
begin;
truncate table project_costs, material_shipments, material_imports, suppliers, service_revenues, project_revenues, risks, revenue_categories, revenue_areas, market_fluctuations, outbox restart identity cascade;

insert into revenue_areas (id, province_name, coefficient) values
  ('BRKV01', 'São Paulo', 0.1),
  ('BRKV02', 'Rio de Janeiro', 0.2),
  ('BRKV03', 'Minas Gerais', 0.3),
  ('BRKV04', 'Paraná', 0.4),
  ('BRKV05', 'Bahia', 0.5),
  ('BRKV06', 'Santa Catarina', 0.6);

insert into revenue_categories (id, name) values
  ('BRLH01', 'Obras públicas'),
  ('BRLH02', 'Instalações esportivas'),
  ('BRLH03', 'Residencial'),
  ('BRLH04', 'Comercial'),
  ('BRLH05', 'Infraestrutura');

insert into risks (id, name, coefficient) values
  ('BRRR01', 'Segurança', 3.1),
  ('BRRR02', 'Atrasos por clima', 2.4),
  ('BRRR03', 'Alta no preço de materiais', 3.8),
  ('BRRR04', 'Atraso em licenças', 2.0);

insert into project_revenues (project_id, category_id, area_id, risk_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('BRDA001', 'BRLH03', 'BRKV04', 'BRRR03', 1.1, 721600.00, 'BRL', 5.36757488, '2026-06-02', 134436.88),
  ('BRDA002', 'BRLH03', 'BRKV06', 'BRRR03', 1.3, 1203400.00, 'BRL', 5.30332337, '2025-08-22', 226914.32),
  ('BRDA003', 'BRLH04', 'BRKV03', 'BRRR03', 1.15, 1265000.00, 'BRL', 5.39071065, '2026-06-15', 234662.94),
  ('BRDA004', 'BRLH03', 'BRKV03', 'BRRR02', 0.92, 1113200.00, 'BRL', 5.36832621, '2025-08-02', 207364.45),
  ('BRDA005', 'BRLH01', 'BRKV02', 'BRRR03', 1.23, 708400.00, 'BRL', 5.38937180, '2026-09-19', 131443.89),
  ('BRDA006', 'BRLH05', 'BRKV04', 'BRRR03', 1.19, 176000.00, 'BRL', 5.34918431, '2025-01-25', 32902.21),
  ('BRDA007', 'BRLH03', 'BRKV06', 'BRRR04', 1.39, 543400.00, 'BRL', 5.35188071, '2026-02-02', 101534.40),
  ('BRDA008', 'BRLH04', 'BRKV03', 'BRRR04', 1.16, 1311200.00, 'BRL', 5.32101360, '2025-05-21', 246419.22),
  ('BRDA009', 'BRLH04', 'BRKV03', 'BRRR01', 1.3, 327800.00, 'BRL', 5.29773449, '2025-05-28', 61875.51),
  ('BRDA010', 'BRLH04', 'BRKV05', 'BRRR01', 1.1, 657800.00, 'BRL', 5.35151695, '2026-08-08', 122918.42);

insert into service_revenues (id, customer_id, service_type, used_on, expected_price, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('BRDV001', 'BRDN0007', 'Manutenção', '2026-08-27', 800.00, 1035.73, 'BRL', 5.39589136, '2026-08-27', 191.95),
  ('BRDV002', 'BRCN0011', 'Reparo hidráulico', '2026-04-09', 800.00, 779.09, 'BRL', 5.40198799, '2026-04-09', 144.22),
  ('BRDV003', 'BRCN0015', 'Reparo de telhado', '2026-12-17', 800.00, 903.39, 'BRL', 5.37620776, '2026-10-15', 168.04),
  ('BRDV004', 'BRCN0003', 'Manutenção', '2026-03-01', 800.00, 648.97, 'BRL', 5.37947828, '2026-03-01', 120.64),
  ('BRDV005', 'BRCN0015', 'Pintura', '2026-11-12', 800.00, 619.78, 'BRL', 5.37620776, '2026-10-15', 115.28),
  ('BRDV006', 'BRCN0003', 'Reparo de telhado', '2026-08-10', 800.00, 851.87, 'BRL', 5.37789903, '2026-08-10', 158.40),
  ('BRDV007', 'BRCN0008', 'Reparo de telhado', '2026-11-06', 800.00, 1083.02, 'BRL', 5.37620776, '2026-10-15', 201.45),
  ('BRDV008', 'BRDN0010', 'Manutenção', '2025-11-08', 800.00, 752.92, 'BRL', 5.33650535, '2025-11-08', 141.09);

insert into suppliers (id, name, contact, address) values
  ('BRNCC01', 'Materiais de Construção Paulista Ltda', '+55 11 94051-2778', 'Rua São João, 182 – Belo Horizonte – MG, 30100-000'),
  ('BRNCC02', 'Aço Forte Distribuidora', '+55 11 93275-6617', 'Rua das Flores, 227 – São Paulo – SP, 01000-000'),
  ('BRNCC03', 'Concreteira Minas S.A.', '+55 21 95728-9898', 'Rua da Paz, 198 – Curitiba – PR, 80000-000');

insert into material_imports (id, supplier_id, material_name, imported_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('BRN001', 'BRNCC02', 'Tubo de aço 40x40', '2026-08-06', 6961.79, 'BRL', 5.37518301, '2026-08-06', 1295.17),
  ('BRN002', 'BRNCC02', 'Cimento CP II 50 kg', '2026-08-03', 6880.46, 'BRL', 5.36988740, '2026-08-03', 1281.31),
  ('BRN003', 'BRNCC02', 'Concreto usinado 25 MPa', '2025-09-05', 3841.78, 'BRL', 5.37042737, '2025-09-05', 715.36),
  ('BRN004', 'BRNCC03', 'Vergalhão 12 mm', '2025-12-21', 6468.59, 'BRL', 5.33642769, '2025-12-21', 1212.16),
  ('BRN005', 'BRNCC03', 'Tijolos (milheiro)', '2025-08-06', 4105.51, 'BRL', 5.33975681, '2025-08-06', 768.86),
  ('BRN006', 'BRNCC02', 'Tubo de aço 40x40', '2025-10-11', 4937.97, 'BRL', 5.32370889, '2025-10-11', 927.54),
  ('BRN007', 'BRNCC03', 'Cimento CP II 50 kg', '2025-06-01', 7345.04, 'BRL', 5.29478530, '2025-06-01', 1387.22),
  ('BRN008', 'BRNCC02', 'Concreto usinado 25 MPa', '2025-02-24', 4594.00, 'BRL', 5.28006239, '2025-02-24', 870.07);

insert into material_shipments (id, shipped_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('BRVC01', '2025-06-23', 523.14, 'BRL', 5.34379194, '2025-06-23', 97.90),
  ('BRVC02', '2026-08-10', 423.13, 'BRL', 5.37789903, '2026-08-10', 78.68),
  ('BRVC03', '2025-03-11', 133.87, 'BRL', 5.33859139, '2025-03-11', 25.08),
  ('BRVC04', '2026-12-20', 130.47, 'BRL', 5.37620776, '2026-10-15', 24.27),
  ('BRVC05', '2026-05-10', 524.34, 'BRL', 5.34503822, '2026-05-10', 98.10),
  ('BRVC06', '2025-02-23', 263.01, 'BRL', 5.28539008, '2025-02-23', 49.76),
  ('BRVC07', '2026-03-13', 315.12, 'BRL', 5.35328470, '2026-03-13', 58.86),
  ('BRVC08', '2026-02-28', 278.17, 'BRL', 5.36216081, '2026-02-28', 51.88);

insert into project_costs (project_id, import_id, shipment_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('BRDA001', 'BRN001', 'BRVC01', 1.02, 8922.73, 'BRL', 5.37486126, '2026-10-03', 1660.09),
  ('BRDA002', 'BRN002', 'BRVC02', 1.08, 5142.33, 'BRL', 5.35734672, '2026-02-18', 959.86),
  ('BRDA003', 'BRN003', 'BRVC03', 1.08, 8652.07, 'BRL', 5.39860248, '2026-07-16', 1602.65),
  ('BRDA004', 'BRN004', 'BRVC04', 1.08, 2346.71, 'BRL', 5.37620776, '2026-10-15', 436.50),
  ('BRDA005', 'BRN005', 'BRVC05', 1.05, 10983.67, 'BRL', 5.38250305, '2026-07-01', 2040.62),
  ('BRDA006', 'BRN006', 'BRVC06', 1.11, 6815.37, 'BRL', 5.38174004, '2026-02-06', 1266.39),
  ('BRDA007', 'BRN007', 'BRVC07', 1.09, 4956.19, 'BRL', 5.40242803, '2026-09-24', 917.40),
  ('BRDA008', 'BRN008', 'BRVC08', 1.03, 3957.71, 'BRL', 5.33982508, '2025-12-19', 741.17),
  ('BRDA009', 'BRN001', 'BRVC01', 1.15, 3798.84, 'BRL', 5.36563469, '2025-07-17', 707.99),
  ('BRDA010', 'BRN002', 'BRVC02', 1.05, 7662.86, 'BRL', 5.37076375, '2026-04-24', 1426.77);

insert into market_fluctuations (observed_on, coefficient) values
  ('2026-01-05', 0.59),
  ('2026-02-05', 0.52),
  ('2026-03-05', 0.8),
  ('2026-04-05', 0.61),
  ('2026-05-05', 0.71),
  ('2026-06-05', 0.44),
  ('2026-07-05', 0.6),
  ('2026-08-05', 0.64),
  ('2026-09-05', 0.12);

commit;
