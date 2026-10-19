-- Sinh tự động bởi tools/seed_data/generate.py, khu vực au. Không sửa tay.
begin;
truncate table project_costs, material_shipments, material_imports, suppliers, service_revenues, project_revenues, risks, revenue_categories, revenue_areas, market_fluctuations, outbox restart identity cascade;

insert into revenue_areas (id, province_name, coefficient) values
  ('AUKV01', 'New South Wales', 0.1),
  ('AUKV02', 'Victoria', 0.2),
  ('AUKV03', 'Queensland', 0.3),
  ('AUKV04', 'Western Australia', 0.4),
  ('AUKV05', 'South Australia', 0.5);

insert into revenue_categories (id, name) values
  ('AULH01', 'Public works'),
  ('AULH02', 'Sports facilities'),
  ('AULH03', 'Residential'),
  ('AULH04', 'Commercial'),
  ('AULH05', 'Infrastructure');

insert into risks (id, name, coefficient) values
  ('AURR01', 'Site safety', 3.1),
  ('AURR02', 'Weather delays', 2.4),
  ('AURR03', 'Material price increase', 3.8),
  ('AURR04', 'Permit delays', 2.0);

insert into project_revenues (project_id, category_id, area_id, risk_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('AUDA001', 'AULH03', 'AUKV04', 'AURR02', 0.98, 466180.00, 'AUD', 1.50273492, '2025-04-19', 310221.05),
  ('AUDA002', 'AULH04', 'AUKV03', 'AURR04', 1.2, 394680.00, 'AUD', 1.49604827, '2025-02-11', 263815.02),
  ('AUDA003', 'AULH04', 'AUKV05', 'AURR01', 0.98, 228800.00, 'AUD', 1.51368990, '2025-03-19', 151153.81),
  ('AUDA004', 'AULH04', 'AUKV05', 'AURR02', 1.36, 746460.00, 'AUD', 1.53228737, '2026-07-27', 487154.05),
  ('AUDA005', 'AULH02', 'AUKV04', 'AURR01', 1.08, 1083940.00, 'AUD', 1.51439534, '2025-11-25', 715757.62),
  ('AUDA006', 'AULH04', 'AUKV05', 'AURR04', 1.25, 563420.00, 'AUD', 1.51063678, '2026-02-07', 372968.54),
  ('AUDA007', 'AULH05', 'AUKV01', 'AURR03', 1.2, 509080.00, 'AUD', 1.52950059, '2026-06-08', 332840.67),
  ('AUDA008', 'AULH03', 'AUKV04', 'AURR03', 0.92, 1266980.00, 'AUD', 1.52207559, '2026-07-25', 832402.81),
  ('AUDA009', 'AULH04', 'AUKV03', 'AURR01', 1.21, 509080.00, 'AUD', 1.49811205, '2025-03-03', 339814.37),
  ('AUDA010', 'AULH01', 'AUKV01', 'AURR02', 1.09, 769340.00, 'AUD', 1.52195849, '2026-06-21', 505493.42);

insert into service_revenues (id, customer_id, service_type, used_on, expected_price, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('AUDV001', 'AUDN0013', 'Maintenance', '2026-04-23', 1040.00, 1328.59, 'AUD', 1.53031155, '2026-04-23', 868.18),
  ('AUDV002', 'AUCN0011', 'Maintenance', '2025-08-14', 1040.00, 913.43, 'AUD', 1.51576423, '2025-08-14', 602.62),
  ('AUDV003', 'AUCN0015', 'House painting', '2026-03-11', 1040.00, 1252.51, 'AUD', 1.52483753, '2026-03-11', 821.41),
  ('AUDV004', 'AUCN0015', 'Plumbing repair', '2025-08-05', 1040.00, 1120.64, 'AUD', 1.51666204, '2025-08-05', 738.88),
  ('AUDV005', 'AUDN0007', 'Plumbing repair', '2025-04-21', 1040.00, 1066.46, 'AUD', 1.50127679, '2025-04-21', 710.37),
  ('AUDV006', 'AUDN0007', 'Maintenance', '2026-10-04', 1040.00, 1214.28, 'AUD', 1.52625802, '2026-10-04', 795.59),
  ('AUDV007', 'AUCN0012', 'Plumbing repair', '2026-02-11', 1040.00, 1434.76, 'AUD', 1.51387141, '2026-02-11', 947.74),
  ('AUDV008', 'AUDN0013', 'Roof repair', '2026-02-01', 1040.00, 898.21, 'AUD', 1.52718599, '2026-02-01', 588.15);

insert into suppliers (id, name, contact, address) values
  ('AUNCC01', 'Harbour Building Supplies', '+61 418 168 447', '82 Beach Rd, Melbourne VIC 3000'),
  ('AUNCC02', 'Southern Cross Steel', '+61 484 230 147', '140 Station St, Sydney NSW 2000'),
  ('AUNCC03', 'Coastal Concrete Pty Ltd', '+61 438 875 548', '126 King St, Perth WA 6000');

insert into material_imports (id, supplier_id, material_name, imported_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('AUN001', 'AUNCC02', 'Steel box section 40x40', '2026-03-07', 1762.99, 'AUD', 1.51081890, '2026-03-07', 1166.91),
  ('AUN002', 'AUNCC01', 'Portland cement 50 kg', '2025-08-26', 8121.82, 'AUD', 1.50403565, '2025-08-26', 5400.02),
  ('AUN003', 'AUNCC03', 'Ready-mix concrete C25', '2025-12-26', 8275.28, 'AUD', 1.51979891, '2025-12-26', 5444.98),
  ('AUN004', 'AUNCC01', 'Rebar 12 mm', '2026-02-15', 2725.58, 'AUD', 1.52561170, '2026-02-15', 1786.55),
  ('AUN005', 'AUNCC02', 'Bricks (1,000 pcs)', '2025-06-08', 5662.30, 'AUD', 1.50123931, '2025-06-08', 3771.75),
  ('AUN006', 'AUNCC01', 'Steel box section 40x40', '2026-08-19', 7317.53, 'AUD', 1.53836436, '2026-08-19', 4756.70),
  ('AUN007', 'AUNCC03', 'Portland cement 50 kg', '2026-11-17', 5534.26, 'AUD', 1.54046211, '2026-10-15', 3592.60),
  ('AUN008', 'AUNCC01', 'Ready-mix concrete C25', '2025-09-07', 3881.97, 'AUD', 1.51249341, '2025-09-07', 2566.60);

insert into material_shipments (id, shipped_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('AUVC01', '2026-08-25', 614.07, 'AUD', 1.53972290, '2026-08-25', 398.82),
  ('AUVC02', '2026-12-06', 151.36, 'AUD', 1.54046211, '2026-10-15', 98.26),
  ('AUVC03', '2025-01-06', 423.69, 'AUD', 1.49597000, '2025-01-06', 283.22),
  ('AUVC04', '2026-11-03', 225.27, 'AUD', 1.54046211, '2026-10-15', 146.24),
  ('AUVC05', '2025-10-21', 751.57, 'AUD', 1.52332579, '2025-10-21', 493.38),
  ('AUVC06', '2025-06-06', 346.12, 'AUD', 1.51397104, '2025-06-06', 228.62),
  ('AUVC07', '2025-05-02', 205.62, 'AUD', 1.50961520, '2025-05-02', 136.21),
  ('AUVC08', '2026-01-11', 222.97, 'AUD', 1.51280959, '2026-01-11', 147.39);

insert into project_costs (project_id, import_id, shipment_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('AUDA001', 'AUN001', 'AUVC01', 1.01, 15256.05, 'AUD', 1.52890778, '2026-05-22', 9978.40),
  ('AUDA002', 'AUN002', 'AUVC02', 1.04, 12011.21, 'AUD', 1.49755706, '2025-03-26', 8020.54),
  ('AUDA003', 'AUN003', 'AUVC03', 1.03, 10638.58, 'AUD', 1.50607971, '2025-04-17', 7063.76),
  ('AUDA004', 'AUN004', 'AUVC04', 1.04, 12555.78, 'AUD', 1.50886665, '2025-11-15', 8321.33),
  ('AUDA005', 'AUN005', 'AUVC05', 1.06, 11406.35, 'AUD', 1.51693742, '2025-03-18', 7519.33),
  ('AUDA006', 'AUN006', 'AUVC06', 1.02, 10463.53, 'AUD', 1.52775767, '2026-09-06', 6848.94),
  ('AUDA007', 'AUN007', 'AUVC07', 1.15, 8178.12, 'AUD', 1.53280705, '2026-06-23', 5335.39),
  ('AUDA008', 'AUN008', 'AUVC08', 1.0, 13316.59, 'AUD', 1.52001525, '2026-05-02', 8760.82),
  ('AUDA009', 'AUN001', 'AUVC01', 1.1, 5026.40, 'AUD', 1.51313071, '2025-09-24', 3321.85),
  ('AUDA010', 'AUN002', 'AUVC02', 1.04, 8115.44, 'AUD', 1.51136828, '2026-02-08', 5369.60);

insert into market_fluctuations (observed_on, coefficient) values
  ('2026-01-05', 0.41),
  ('2026-02-05', 0.17),
  ('2026-03-05', 0.37),
  ('2026-04-05', 0.73),
  ('2026-05-05', 0.74),
  ('2026-06-05', 0.21),
  ('2026-07-05', 0.43),
  ('2026-08-05', 0.6),
  ('2026-09-05', 0.73);

commit;
