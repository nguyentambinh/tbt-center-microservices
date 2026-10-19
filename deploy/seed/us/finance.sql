-- Sinh tự động bởi tools/seed_data/generate.py, khu vực us. Không sửa tay.
begin;
truncate table project_costs, material_shipments, material_imports, suppliers, service_revenues, project_revenues, risks, revenue_categories, revenue_areas, market_fluctuations, outbox restart identity cascade;

insert into revenue_areas (id, province_name, coefficient) values
  ('USKV01', 'New York', 0.1),
  ('USKV02', 'Illinois', 0.2),
  ('USKV03', 'California', 0.3),
  ('USKV04', 'Texas', 0.4),
  ('USKV05', 'Florida', 0.5),
  ('USKV06', 'Washington', 0.6);

insert into revenue_categories (id, name) values
  ('USLH01', 'Public works'),
  ('USLH02', 'Sports facilities'),
  ('USLH03', 'Residential'),
  ('USLH04', 'Commercial'),
  ('USLH05', 'Infrastructure');

insert into risks (id, name, coefficient) values
  ('USRR01', 'Site safety', 3.1),
  ('USRR02', 'Weather delays', 2.4),
  ('USRR03', 'Material price increase', 3.8),
  ('USRR04', 'Permit delays', 2.0);

insert into project_revenues (project_id, category_id, area_id, risk_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('USDA001', 'USLH01', 'USKV06', 'USRR01', 0.93, 1045000.00, 'USD', 1.00000000, '2026-10-15', 1045000.00),
  ('USDA002', 'USLH04', 'USKV05', 'USRR03', 1.09, 1102200.00, 'USD', 1.00000000, '2025-12-04', 1102200.00),
  ('USDA003', 'USLH01', 'USKV05', 'USRR04', 1.14, 1251800.00, 'USD', 1.00000000, '2026-06-02', 1251800.00),
  ('USDA004', 'USLH02', 'USKV04', 'USRR02', 1.14, 928400.00, 'USD', 1.00000000, '2025-07-06', 928400.00),
  ('USDA005', 'USLH05', 'USKV04', 'USRR04', 1.34, 1293600.00, 'USD', 1.00000000, '2025-08-07', 1293600.00),
  ('USDA006', 'USLH03', 'USKV03', 'USRR02', 1.18, 950400.00, 'USD', 1.00000000, '2026-04-04', 950400.00),
  ('USDA007', 'USLH02', 'USKV04', 'USRR04', 0.98, 440000.00, 'USD', 1.00000000, '2026-09-23', 440000.00),
  ('USDA008', 'USLH03', 'USKV04', 'USRR04', 1.06, 708400.00, 'USD', 1.00000000, '2025-05-01', 708400.00),
  ('USDA009', 'USLH05', 'USKV01', 'USRR01', 1.32, 264000.00, 'USD', 1.00000000, '2025-01-24', 264000.00),
  ('USDA010', 'USLH03', 'USKV02', 'USRR03', 0.97, 1001000.00, 'USD', 1.00000000, '2025-12-01', 1001000.00);

insert into service_revenues (id, customer_id, service_type, used_on, expected_price, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('USDV001', 'USCN0012', 'Roof repair', '2025-12-10', 800.00, 914.79, 'USD', 1.00000000, '2025-12-10', 914.79),
  ('USDV002', 'USDN0007', 'House painting', '2025-09-21', 800.00, 1186.25, 'USD', 1.00000000, '2025-09-21', 1186.25),
  ('USDV003', 'USCN0009', 'House painting', '2026-02-16', 800.00, 749.38, 'USD', 1.00000000, '2026-02-16', 749.38),
  ('USDV004', 'USCN0006', 'Maintenance', '2026-06-20', 800.00, 751.80, 'USD', 1.00000000, '2026-06-20', 751.80),
  ('USDV005', 'USCN0002', 'Roof repair', '2026-08-21', 800.00, 1169.90, 'USD', 1.00000000, '2026-08-21', 1169.90),
  ('USDV006', 'USCN0015', 'Roof repair', '2025-03-02', 800.00, 1182.00, 'USD', 1.00000000, '2025-03-02', 1182.00),
  ('USDV007', 'USCN0003', 'Maintenance', '2026-02-26', 800.00, 920.32, 'USD', 1.00000000, '2026-02-26', 920.32),
  ('USDV008', 'USCN0002', 'House painting', '2026-02-27', 800.00, 816.61, 'USD', 1.00000000, '2026-02-27', 816.61);

insert into suppliers (id, name, contact, address) values
  ('USNCC01', 'Summit Building Supply Inc.', '+1 (212) 555-0175', '128 Oak Ave, Houston, TX 77002'),
  ('USNCC02', 'Great Lakes Steel Co.', '+1 (213) 555-0154', '161 Oak Ave, Chicago, IL 60601'),
  ('USNCC03', 'Pacific Ready Mix LLC', '+1 (212) 555-0168', '11 Oak Ave, Los Angeles, CA 90012');

insert into material_imports (id, supplier_id, material_name, imported_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('USN001', 'USNCC02', 'Steel box section 40x40', '2026-11-22', 2975.35, 'USD', 1.00000000, '2026-10-15', 2975.35),
  ('USN002', 'USNCC01', 'Portland cement 50 kg', '2026-10-04', 7440.29, 'USD', 1.00000000, '2026-10-04', 7440.29),
  ('USN003', 'USNCC01', 'Ready-mix concrete C25', '2025-07-13', 2091.61, 'USD', 1.00000000, '2025-07-13', 2091.61),
  ('USN004', 'USNCC03', 'Rebar 12 mm', '2026-01-28', 3168.48, 'USD', 1.00000000, '2026-01-28', 3168.48),
  ('USN005', 'USNCC01', 'Bricks (1,000 pcs)', '2026-11-01', 3197.37, 'USD', 1.00000000, '2026-10-15', 3197.37),
  ('USN006', 'USNCC02', 'Steel box section 40x40', '2025-12-09', 7220.45, 'USD', 1.00000000, '2025-12-09', 7220.45),
  ('USN007', 'USNCC02', 'Portland cement 50 kg', '2026-09-05', 5357.61, 'USD', 1.00000000, '2026-09-05', 5357.61),
  ('USN008', 'USNCC03', 'Ready-mix concrete C25', '2026-11-10', 2457.41, 'USD', 1.00000000, '2026-10-15', 2457.41);

insert into material_shipments (id, shipped_on, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('USVC01', '2025-05-11', 417.73, 'USD', 1.00000000, '2025-05-11', 417.73),
  ('USVC02', '2026-01-05', 411.25, 'USD', 1.00000000, '2026-01-05', 411.25),
  ('USVC03', '2026-04-10', 389.45, 'USD', 1.00000000, '2026-04-10', 389.45),
  ('USVC04', '2026-01-21', 273.98, 'USD', 1.00000000, '2026-01-21', 273.98),
  ('USVC05', '2026-02-18', 413.09, 'USD', 1.00000000, '2026-02-18', 413.09),
  ('USVC06', '2026-06-02', 457.00, 'USD', 1.00000000, '2026-06-02', 457.00),
  ('USVC07', '2026-10-21', 387.11, 'USD', 1.00000000, '2026-10-15', 387.11),
  ('USVC08', '2026-05-12', 354.14, 'USD', 1.00000000, '2026-05-12', 354.14);

insert into project_costs (project_id, import_id, shipment_id, change_coefficient, amount_original, currency_original, rate_applied, rate_date, amount_base) values
  ('USDA001', 'USN001', 'USVC01', 1.2, 11760.60, 'USD', 1.00000000, '2026-08-04', 11760.60),
  ('USDA002', 'USN002', 'USVC02', 1.02, 3441.30, 'USD', 1.00000000, '2026-07-16', 3441.30),
  ('USDA003', 'USN003', 'USVC03', 1.07, 6338.21, 'USD', 1.00000000, '2025-07-09', 6338.21),
  ('USDA004', 'USN004', 'USVC04', 1.17, 3412.09, 'USD', 1.00000000, '2026-07-27', 3412.09),
  ('USDA005', 'USN005', 'USVC05', 1.08, 9586.38, 'USD', 1.00000000, '2025-05-17', 9586.38),
  ('USDA006', 'USN006', 'USVC06', 1.08, 4265.36, 'USD', 1.00000000, '2026-08-11', 4265.36),
  ('USDA007', 'USN007', 'USVC07', 1.19, 9858.41, 'USD', 1.00000000, '2026-03-12', 9858.41),
  ('USDA008', 'USN008', 'USVC08', 1.12, 11717.96, 'USD', 1.00000000, '2025-09-07', 11717.96),
  ('USDA009', 'USN001', 'USVC01', 1.05, 11478.12, 'USD', 1.00000000, '2026-08-03', 11478.12),
  ('USDA010', 'USN002', 'USVC02', 1.01, 6576.74, 'USD', 1.00000000, '2025-02-10', 6576.74);

insert into market_fluctuations (observed_on, coefficient) values
  ('2026-01-05', 0.19),
  ('2026-02-05', 0.12),
  ('2026-03-05', 0.27),
  ('2026-04-05', 0.86),
  ('2026-05-05', 0.2),
  ('2026-06-05', 0.1),
  ('2026-07-05', 0.17),
  ('2026-08-05', 0.82),
  ('2026-09-05', 0.87);

commit;
