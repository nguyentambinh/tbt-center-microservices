-- Sinh tự động bởi tools/seed_data/generate.py, khu vực de. Không sửa tay.
begin;
truncate table project_costs, material_shipments, material_imports, suppliers, service_revenues, project_revenues, risks, revenue_categories, revenue_areas, market_fluctuations, outbox restart identity cascade;

insert into revenue_areas (id, province_name, coefficient) values
  ('DEKV01', 'Berlin', 0.1),
  ('DEKV02', 'Bayern', 0.2),
  ('DEKV03', 'Hamburg', 0.3),
  ('DEKV04', 'Hessen', 0.4),
  ('DEKV05', 'Nordrhein-Westfalen', 0.5),
  ('DEKV06', 'Baden-Württemberg', 0.6);

insert into revenue_categories (id, name) values
  ('DELH01', 'Öffentliche Bauten'),
  ('DELH02', 'Sportstätten'),
  ('DELH03', 'Wohnungsbau'),
  ('DELH04', 'Gewerbebau'),
  ('DELH05', 'Infrastruktur');

insert into risks (id, name, coefficient) values
  ('DERR01', 'Arbeitssicherheit', 3.1),
  ('DERR02', 'Wetterbedingte Verzögerung', 2.4),
  ('DERR03', 'Materialpreisanstieg', 3.8),
  ('DERR04', 'Genehmigungsverzögerung', 2.0);

insert into project_revenues (project_id, category_id, area_id, risk_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('DEDA001', 'DELH03', 'DEKV06', 'DERR01', 1.35, 839850.00, 'EUR', 0.86377680, '2026-06-06', 972299.79),
  ('DEDA002', 'DELH05', 'DEKV02', 'DERR02', 1.22, 437250.00, 'EUR', 0.86502057, '2026-10-15', 505479.31),
  ('DEDA003', 'DELH01', 'DEKV02', 'DERR02', 1.39, 582450.00, 'EUR', 0.86734615, '2026-06-02', 671531.20),
  ('DEDA004', 'DELH03', 'DEKV03', 'DERR03', 1.09, 750750.00, 'EUR', 0.85730687, '2026-09-17', 875707.43),
  ('DEDA005', 'DELH02', 'DEKV04', 'DERR02', 0.93, 653400.00, 'EUR', 0.86979582, '2026-06-22', 751210.78),
  ('DEDA006', 'DELH04', 'DEKV05', 'DERR01', 1.19, 623700.00, 'EUR', 0.87216099, '2026-02-01', 715120.27),
  ('DEDA007', 'DELH04', 'DEKV03', 'DERR04', 0.97, 947100.00, 'EUR', 0.86502057, '2026-10-15', 1094887.26),
  ('DEDA008', 'DELH05', 'DEKV06', 'DERR01', 0.94, 511500.00, 'EUR', 0.88641340, '2025-04-02', 577044.53),
  ('DEDA009', 'DELH04', 'DEKV05', 'DERR02', 1.11, 397650.00, 'EUR', 0.86474872, '2026-03-14', 459844.57),
  ('DEDA010', 'DELH03', 'DEKV03', 'DERR02', 1.38, 132000.00, 'EUR', 0.86538988, '2026-09-06', 152532.41);

insert into service_revenues (id, customer_id, service_type, used_on, expected_price, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('DEDV001', 'DECN0014', 'Malerarbeiten', '2026-03-10', 600.00, 795.44, 'EUR', 0.87769657, '2026-03-10', 906.28),
  ('DEDV002', 'DEDN0004', 'Malerarbeiten', '2026-01-18', 600.00, 761.79, 'EUR', 0.86853588, '2026-01-18', 877.10),
  ('DEDV003', 'DECN0002', 'Malerarbeiten', '2025-05-08', 600.00, 740.43, 'EUR', 0.89079036, '2025-05-08', 831.21),
  ('DEDV004', 'DECN0009', 'Wartung', '2026-12-22', 600.00, 864.92, 'EUR', 0.86502057, '2026-10-15', 999.89),
  ('DEDV005', 'DECN0009', 'Dachreparatur', '2025-01-27', 600.00, 891.91, 'EUR', 0.89782827, '2025-01-27', 993.41),
  ('DEDV006', 'DECN0014', 'Sanitärreparatur', '2026-05-24', 600.00, 475.54, 'EUR', 0.86738219, '2026-05-24', 548.25),
  ('DEDV007', 'DECN0006', 'Dachreparatur', '2025-03-05', 600.00, 478.78, 'EUR', 0.89107038, '2025-03-05', 537.30),
  ('DEDV008', 'DECN0002', 'Wartung', '2026-12-16', 600.00, 525.88, 'EUR', 0.86502057, '2026-10-15', 607.94);

insert into suppliers (id, name, contact, address) values
  ('DENCC01', 'Baustoffe Schmidt GmbH', '+49 154 9236710', 'Goethestraße 128, 50667 Köln'),
  ('DENCC02', 'Stahlhandel Nord AG', '+49 151 4304743', 'Lindenweg 111, 80331 München'),
  ('DENCC03', 'Beton Süd GmbH', '+49 155 7327483', 'Hauptstraße 141, 50667 Köln');

insert into material_imports (id, supplier_id, material_name, imported_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('DEN001', 'DENCC02', 'Stahlrohr 40x40', '2025-09-21', 3200.45, 'EUR', 0.88329635, '2025-09-21', 3623.30),
  ('DEN002', 'DENCC02', 'Portlandzement 25 kg', '2026-11-11', 3824.23, 'EUR', 0.86502057, '2026-10-15', 4420.97),
  ('DEN003', 'DENCC02', 'Transportbeton C25/30', '2025-07-24', 2095.37, 'EUR', 0.88202915, '2025-07-24', 2375.63),
  ('DEN004', 'DENCC02', 'Betonstahl 12 mm', '2026-12-05', 4442.57, 'EUR', 0.86502057, '2026-10-15', 5135.80),
  ('DEN005', 'DENCC03', 'Ziegelsteine (1.000 Stk.)', '2025-03-19', 3874.33, 'EUR', 0.88724930, '2025-03-19', 4366.68),
  ('DEN006', 'DENCC02', 'Stahlrohr 40x40', '2026-05-09', 3164.77, 'EUR', 0.87081471, '2026-05-09', 3634.27),
  ('DEN007', 'DENCC02', 'Portlandzement 25 kg', '2026-04-09', 4415.49, 'EUR', 0.86523733, '2026-04-09', 5103.21),
  ('DEN008', 'DENCC01', 'Transportbeton C25/30', '2026-11-18', 4693.58, 'EUR', 0.86502057, '2026-10-15', 5425.97);

insert into material_shipments (id, shipped_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('DEVC01', '2026-08-07', 103.36, 'EUR', 0.85698499, '2026-08-07', 120.61),
  ('DEVC02', '2026-12-26', 168.39, 'EUR', 0.86502057, '2026-10-15', 194.67),
  ('DEVC03', '2025-04-11', 239.27, 'EUR', 0.88358838, '2025-04-11', 270.79),
  ('DEVC04', '2025-04-05', 108.46, 'EUR', 0.89327927, '2025-04-05', 121.42),
  ('DEVC05', '2026-06-19', 323.95, 'EUR', 0.86665689, '2026-06-19', 373.79),
  ('DEVC06', '2025-12-05', 130.54, 'EUR', 0.87482428, '2025-12-05', 149.22),
  ('DEVC07', '2025-10-28', 157.49, 'EUR', 0.87471169, '2025-10-28', 180.05),
  ('DEVC08', '2026-09-06', 325.64, 'EUR', 0.86538988, '2026-09-06', 376.29);

insert into project_costs (project_id, import_id, shipment_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('DEDA001', 'DEN001', 'DEVC01', 1.2, 6109.64, 'EUR', 0.85627146, '2026-08-20', 7135.17),
  ('DEDA002', 'DEN002', 'DEVC02', 1.01, 8385.92, 'EUR', 0.86509047, '2026-08-13', 9693.69),
  ('DEDA003', 'DEN003', 'DEVC03', 1.01, 7558.11, 'EUR', 0.87968059, '2025-09-12', 8591.88),
  ('DEDA004', 'DEN004', 'DEVC04', 1.03, 2793.72, 'EUR', 0.86502057, '2026-10-15', 3229.66),
  ('DEDA005', 'DEN005', 'DEVC05', 1.08, 4504.86, 'EUR', 0.86810087, '2026-04-10', 5189.32),
  ('DEDA006', 'DEN006', 'DEVC06', 1.07, 4824.90, 'EUR', 0.87154024, '2025-11-14', 5536.06),
  ('DEDA007', 'DEN007', 'DEVC07', 1.07, 4960.56, 'EUR', 0.86568884, '2026-03-23', 5730.19),
  ('DEDA008', 'DEN008', 'DEVC08', 1.13, 7732.82, 'EUR', 0.88063219, '2025-11-22', 8780.99),
  ('DEDA009', 'DEN001', 'DEVC01', 1.19, 6740.18, 'EUR', 0.86923524, '2026-06-24', 7754.15),
  ('DEDA010', 'DEN002', 'DEVC02', 1.08, 1930.59, 'EUR', 0.88270823, '2025-05-21', 2187.12);

insert into market_fluctuations (observed_on, coefficient) values
  ('2026-01-05', 0.83),
  ('2026-02-05', 0.35),
  ('2026-03-05', 0.12),
  ('2026-04-05', 0.81),
  ('2026-05-05', 0.34),
  ('2026-06-05', 0.36),
  ('2026-07-05', 0.66),
  ('2026-08-05', 0.78),
  ('2026-09-05', 0.86);

commit;
