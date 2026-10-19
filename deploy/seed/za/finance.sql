-- Sinh tự động bởi tools/seed_data/generate.py, khu vực za. Không sửa tay.
begin;
truncate table project_costs, material_shipments, material_imports, suppliers, service_revenues, project_revenues, risks, revenue_categories, revenue_areas, market_fluctuations, outbox restart identity cascade;

insert into revenue_areas (id, province_name, coefficient) values
  ('ZAKV01', 'Gauteng', 0.1),
  ('ZAKV02', 'Western Cape', 0.2),
  ('ZAKV03', 'KwaZulu-Natal', 0.3),
  ('ZAKV04', 'Eastern Cape', 0.4),
  ('ZAKV05', 'Free State', 0.5);

insert into revenue_categories (id, name) values
  ('ZALH01', 'Public works'),
  ('ZALH02', 'Sports facilities'),
  ('ZALH03', 'Residential'),
  ('ZALH04', 'Commercial'),
  ('ZALH05', 'Infrastructure');

insert into risks (id, name, coefficient) values
  ('ZARR01', 'Site safety', 3.1),
  ('ZARR02', 'Weather delays', 2.4),
  ('ZARR03', 'Material price increase', 3.8),
  ('ZARR04', 'Permit delays', 2.0);

insert into project_revenues (project_id, category_id, area_id, risk_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('ZADA001', 'ZALH03', 'ZAKV03', 'ZARR04', 0.98, 4643100.00, 'ZAR', 17.50607621, '2026-03-28', 265227.91),
  ('ZADA002', 'ZALH01', 'ZAKV02', 'ZARR02', 1.09, 5217300.00, 'ZAR', 17.42365099, '2025-08-26', 299437.82),
  ('ZADA003', 'ZALH04', 'ZAKV03', 'ZARR04', 1.06, 5712300.00, 'ZAR', 17.61162999, '2026-10-10', 324348.17),
  ('ZADA004', 'ZALH03', 'ZAKV01', 'ZARR03', 1.11, 1158300.00, 'ZAR', 17.61117583, '2026-08-12', 65770.74),
  ('ZADA005', 'ZALH02', 'ZAKV03', 'ZARR01', 0.93, 2514600.00, 'ZAR', 17.37694195, '2026-01-13', 144709.01),
  ('ZADA006', 'ZALH01', 'ZAKV05', 'ZARR04', 1.34, 683100.00, 'ZAR', 17.33471712, '2025-03-23', 39406.47),
  ('ZADA007', 'ZALH04', 'ZAKV02', 'ZARR02', 1.03, 2682900.00, 'ZAR', 17.39867299, '2026-05-15', 154201.42),
  ('ZADA008', 'ZALH03', 'ZAKV03', 'ZARR04', 1.02, 5841000.00, 'ZAR', 17.30277374, '2026-01-23', 337575.93),
  ('ZADA009', 'ZALH01', 'ZAKV01', 'ZARR01', 1.12, 4019400.00, 'ZAR', 17.49051593, '2026-07-12', 229804.54),
  ('ZADA010', 'ZALH02', 'ZAKV03', 'ZARR04', 0.96, 4940100.00, 'ZAR', 17.31600301, '2025-02-23', 285291.01);

insert into service_revenues (id, customer_id, service_type, used_on, expected_price, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('ZADV001', 'ZACN0014', 'House painting', '2025-05-02', 3600.00, 3762.77, 'ZAR', 17.29787928, '2025-05-02', 217.53),
  ('ZADV002', 'ZACN0011', 'Maintenance', '2025-09-23', 3600.00, 4390.81, 'ZAR', 17.34061257, '2025-09-23', 253.21),
  ('ZADV003', 'ZADN0007', 'House painting', '2026-08-20', 3600.00, 4593.72, 'ZAR', 17.45087742, '2026-08-20', 263.24),
  ('ZADV004', 'ZACN0014', 'House painting', '2026-03-07', 3600.00, 3397.30, 'ZAR', 17.52058152, '2026-03-07', 193.90),
  ('ZADV005', 'ZADN0001', 'Maintenance', '2025-10-04', 3600.00, 4910.10, 'ZAR', 17.30579666, '2025-10-04', 283.73),
  ('ZADV006', 'ZADN0013', 'House painting', '2025-04-17', 3600.00, 4241.44, 'ZAR', 17.40944497, '2025-04-17', 243.63),
  ('ZADV007', 'ZACN0002', 'Roof repair', '2025-05-20', 3600.00, 3736.81, 'ZAR', 17.23660042, '2025-05-20', 216.80),
  ('ZADV008', 'ZACN0014', 'Plumbing repair', '2025-02-20', 3600.00, 3936.97, 'ZAR', 17.35547323, '2025-02-20', 226.84);

insert into suppliers (id, name, contact, address) values
  ('ZANCC01', 'Highveld Building Supplies', '+27 83 115 5227', '167 Jan Smuts Ave, Durban, 4001'),
  ('ZANCC02', 'Cape Steel Merchants', '+27 71 239 3402', '38 Beach Rd, Pretoria, 0002'),
  ('ZANCC03', 'Natal Readymix (Pty) Ltd', '+27 82 377 2016', '239 Beach Rd, Cape Town, 8001');

insert into material_imports (id, supplier_id, material_name, imported_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('ZAN001', 'ZANCC02', 'Steel box section 40x40', '2026-02-08', 29912.82, 'ZAR', 17.35848301, '2026-02-08', 1723.24),
  ('ZAN002', 'ZANCC02', 'Portland cement 50 kg', '2026-06-08', 7217.75, 'ZAR', 17.33956692, '2026-06-08', 416.26),
  ('ZAN003', 'ZANCC01', 'Ready-mix concrete C25', '2026-01-19', 34657.87, 'ZAR', 17.28324344, '2026-01-19', 2005.29),
  ('ZAN004', 'ZANCC01', 'Rebar 12 mm', '2026-11-24', 11541.68, 'ZAR', 17.60176165, '2026-10-15', 655.71),
  ('ZAN005', 'ZANCC03', 'Bricks (1,000 pcs)', '2026-11-04', 23977.09, 'ZAR', 17.60176165, '2026-10-15', 1362.20),
  ('ZAN006', 'ZANCC02', 'Steel box section 40x40', '2025-06-26', 10152.73, 'ZAR', 17.32925069, '2025-06-26', 585.87),
  ('ZAN007', 'ZANCC03', 'Portland cement 50 kg', '2026-10-09', 27356.20, 'ZAR', 17.49955295, '2026-10-09', 1563.25),
  ('ZAN008', 'ZANCC02', 'Ready-mix concrete C25', '2025-08-26', 22502.98, 'ZAR', 17.42365099, '2025-08-26', 1291.52);

insert into material_shipments (id, shipped_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('ZAVC01', '2025-10-22', 2584.92, 'ZAR', 17.46702860, '2025-10-22', 147.99),
  ('ZAVC02', '2026-08-19', 2380.77, 'ZAR', 17.34206956, '2026-08-19', 137.28),
  ('ZAVC03', '2026-01-18', 1296.90, 'ZAR', 17.53808810, '2026-01-18', 73.95),
  ('ZAVC04', '2025-09-15', 915.15, 'ZAR', 17.26838313, '2025-09-15', 53.00),
  ('ZAVC05', '2025-10-14', 1727.13, 'ZAR', 17.40406837, '2025-10-14', 99.24),
  ('ZAVC06', '2026-08-07', 1249.37, 'ZAR', 17.60002056, '2026-08-07', 70.99),
  ('ZAVC07', '2026-12-19', 2529.64, 'ZAR', 17.60176165, '2026-10-15', 143.72),
  ('ZAVC08', '2026-01-11', 1328.10, 'ZAR', 17.29534831, '2026-01-11', 76.79);

insert into project_costs (project_id, import_id, shipment_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('ZADA001', 'ZAN001', 'ZAVC01', 1.13, 19909.11, 'ZAR', 17.42564999, '2026-07-26', 1142.52),
  ('ZADA002', 'ZAN002', 'ZAVC02', 1.05, 25704.72, 'ZAR', 17.61280499, '2026-08-27', 1459.43),
  ('ZADA003', 'ZAN003', 'ZAVC03', 1.04, 16152.73, 'ZAR', 17.38102524, '2025-09-06', 929.33),
  ('ZADA004', 'ZAN004', 'ZAVC04', 1.08, 18915.42, 'ZAR', 17.34719054, '2025-11-25', 1090.40),
  ('ZADA005', 'ZAN005', 'ZAVC05', 1.07, 34631.22, 'ZAR', 17.27448490, '2025-03-27', 2004.76),
  ('ZADA006', 'ZAN006', 'ZAVC06', 1.05, 41277.25, 'ZAR', 17.60176165, '2026-10-15', 2345.06),
  ('ZADA007', 'ZAN007', 'ZAVC07', 1.09, 24715.91, 'ZAR', 17.35838774, '2025-12-22', 1423.86),
  ('ZADA008', 'ZAN008', 'ZAVC08', 1.05, 27364.52, 'ZAR', 17.37541335, '2025-07-28', 1574.90),
  ('ZADA009', 'ZAN001', 'ZAVC01', 1.07, 21771.21, 'ZAR', 17.52717932, '2026-04-13', 1242.14),
  ('ZADA010', 'ZAN002', 'ZAVC02', 1.1, 18135.02, 'ZAR', 17.30012824, '2025-06-02', 1048.26);

insert into market_fluctuations (observed_on, coefficient) values
  ('2026-01-05', 0.42),
  ('2026-02-05', 0.86),
  ('2026-03-05', 0.88),
  ('2026-04-05', 0.62),
  ('2026-05-05', 0.67),
  ('2026-06-05', 0.36),
  ('2026-07-05', 0.83),
  ('2026-08-05', 0.28),
  ('2026-09-05', 0.8);

commit;
