-- Sinh tự động bởi tools/seed_data/generate.py, khu vực za. Không sửa tay.
begin;
truncate table project_members, project_contracts, projects, contracts, customers, outbox restart identity cascade;

insert into customers (id, country_code, customer_type, name, contact, address) values
  ('ZADN0001', 'ZA', 'business', 'Naidoo Developments (Pty) Ltd', '+27 83 615 1263', '246 Main Rd, Pretoria, 0002'),
  ('ZACN0002', 'ZA', 'individual', 'Thandiwe Molefe', '+27 72 655 5040', '236 Church St, Durban, 4001'),
  ('ZACN0003', 'ZA', 'individual', 'Thabo Pillay', '+27 71 880 7109', '85 Church St, Gqeberha, 6001'),
  ('ZADN0004', 'ZA', 'business', 'Khumalo Holdings', '+27 71 521 6621', '140 Beach Rd, Gqeberha, 6001'),
  ('ZACN0005', 'ZA', 'individual', 'Bongani Botha', '+27 72 827 1114', '34 Long St, Cape Town, 8001'),
  ('ZACN0006', 'ZA', 'individual', 'Palesa Nkosi', '+27 83 337 3229', '95 Main Rd, Pretoria, 0002'),
  ('ZADN0007', 'ZA', 'business', 'Pillay Holdings', '+27 71 652 8639', '146 Main Rd, Pretoria, 0002'),
  ('ZACN0008', 'ZA', 'individual', 'Bongani Botha', '+27 71 866 1483', '195 Church St, Durban, 4001'),
  ('ZACN0009', 'ZA', 'individual', 'Pieter Molefe', '+27 72 387 8025', '40 Long St, Pretoria, 0002'),
  ('ZADN0010', 'ZA', 'business', 'Ndlovu Developments (Pty) Ltd', '+27 82 155 4992', '208 Long St, Gqeberha, 6001'),
  ('ZACN0011', 'ZA', 'individual', 'Ruan Khumalo', '+27 72 656 1645', '114 Church St, Durban, 4001'),
  ('ZACN0012', 'ZA', 'individual', 'Mandla van der Merwe', '+27 71 904 3533', '162 Main Rd, Cape Town, 8001'),
  ('ZADN0013', 'ZA', 'business', 'Dlamini Properties (Pty) Ltd', '+27 71 143 9431', '94 Beach Rd, Pretoria, 0002'),
  ('ZACN0014', 'ZA', 'individual', 'Pieter Pillay', '+27 71 799 1863', '31 Church St, Pretoria, 0002'),
  ('ZACN0015', 'ZA', 'individual', 'Zanele Venter', '+27 72 710 8393', '130 Voortrekker Rd, Johannesburg, 2001');

insert into contracts (id, country_code, name, contract_type, start_date, expected_end_date) values
  ('ZAHD001', 'ZA', 'Residential house construction', '1', '2026-07-23', '2027-05-08'),
  ('ZAHD002', 'ZA', 'Villa construction', '2', '2024-06-03', '2025-07-04'),
  ('ZAHD003', 'ZA', 'Office building', '3', '2024-04-08', '2024-12-16'),
  ('ZAHD004', 'ZA', 'Warehouse', '4', '2026-10-25', '2027-04-25'),
  ('ZAHD005', 'ZA', 'Bridge and road works', '1', '2026-06-14', '2027-04-29'),
  ('ZAHD006', 'ZA', 'School renovation', '2', '2025-04-02', '2026-04-12'),
  ('ZAHD007', 'ZA', 'Shopping centre fit-out', '3', '2025-02-10', '2025-08-19'),
  ('ZAHD008', 'ZA', 'Apartment block', '4', '2024-02-24', '2024-08-11'),
  ('ZAHD009', 'ZA', 'Residential house construction', '1', '2025-01-11', '2026-03-04'),
  ('ZAHD010', 'ZA', 'Villa construction', '2', '2025-09-28', '2027-01-17');

insert into projects (id, company_id, country_code, customer_id, deposit_amount, expected_acceptance_amount, currency) values
  ('ZADA001', 'TBTJNB', 'ZA', 'ZACN0012', 1266300.00, 4221000.00, 'ZAR'),
  ('ZADA002', 'TBTCPT', 'ZA', 'ZACN0005', 1422900.00, 4743000.00, 'ZAR'),
  ('ZADA003', 'TBTDUR', 'ZA', 'ZACN0012', 1557900.00, 5193000.00, 'ZAR'),
  ('ZADA004', 'TBTJNB', 'ZA', 'ZACN0015', 315900.00, 1053000.00, 'ZAR'),
  ('ZADA005', 'TBTCPT', 'ZA', 'ZACN0009', 685800.00, 2286000.00, 'ZAR'),
  ('ZADA006', 'TBTDUR', 'ZA', 'ZADN0007', 186300.00, 621000.00, 'ZAR'),
  ('ZADA007', 'TBTJNB', 'ZA', 'ZACN0015', 731700.00, 2439000.00, 'ZAR'),
  ('ZADA008', 'TBTDUR', 'ZA', 'ZACN0011', 1593000.00, 5310000.00, 'ZAR'),
  ('ZADA009', 'TBTDUR', 'ZA', 'ZACN0008', 1096200.00, 3654000.00, 'ZAR'),
  ('ZADA010', 'TBTJNB', 'ZA', 'ZACN0005', 1347300.00, 4491000.00, 'ZAR');

insert into project_contracts (id, project_id, contract_id, end_date) values
  ('ZA2026072300', 'ZADA001', 'ZAHD001', '2027-04-24'),
  ('ZA2024060301', 'ZADA002', 'ZAHD002', '2024-11-13'),
  ('ZA2024040802', 'ZADA003', 'ZAHD003', '2025-08-07'),
  ('ZA2026102503', 'ZADA004', 'ZAHD004', '2027-06-07'),
  ('ZA2026061404', 'ZADA005', 'ZAHD005', '2027-07-08'),
  ('ZA2025040205', 'ZADA006', 'ZAHD006', '2025-11-19'),
  ('ZA2025021006', 'ZADA007', 'ZAHD007', '2025-12-22'),
  ('ZA2024022407', 'ZADA008', 'ZAHD008', '2024-08-09'),
  ('ZA2025011108', 'ZADA009', 'ZAHD009', '2025-09-30'),
  ('ZA2025092809', 'ZADA010', 'ZAHD010', '2026-04-15');

insert into project_members (project_contract_id, employee_id, total_hours, project_salary) values
  ('ZA2026072300', 'SIP74032CPT', 201, 18034.08),
  ('ZA2026072300', 'PIE85014CPT', 170, 22288.06),
  ('ZA2026072300', 'SIP69037JNB', 182, 18785.44),
  ('ZA2026072300', 'BUS81036DUR', 166, 12150.19),
  ('ZA2024060301', 'AYA61017CPT', 115, 19221.70),
  ('ZA2024060301', 'SIZ81027DUR', 186, 11873.80),
  ('ZA2024060301', 'KAG90039DUR', 124, 14124.07),
  ('ZA2024060301', 'SIZ81009DUR', 113, 24801.31),
  ('ZA2024040802', 'JOH91002CPT', 208, 22178.88),
  ('ZA2024040802', 'AYA61017CPT', 175, 17758.84),
  ('ZA2024040802', 'LER80025JNB', 156, 14559.61),
  ('ZA2024040802', 'MAN64001JNB', 163, 26061.48),
  ('ZA2026102503', 'JOH95007JNB', 134, 9151.23),
  ('ZA2026102503', 'LER92022JNB', 101, 22592.64),
  ('ZA2026102503', 'KAB77015DUR', 204, 26505.93),
  ('ZA2026102503', 'SIZ96016JNB', 109, 18054.17),
  ('ZA2026061404', 'MAN64001JNB', 172, 17999.51),
  ('ZA2026061404', 'BON70021DUR', 112, 24231.14),
  ('ZA2026061404', 'SIZ81027DUR', 164, 22580.49),
  ('ZA2026061404', 'SIZ94023CPT', 166, 15809.99),
  ('ZA2025040205', 'LER77038CPT', 184, 23718.08),
  ('ZA2025040205', 'THA63029CPT', 103, 25951.78),
  ('ZA2025040205', 'JOH95007JNB', 91, 12271.21),
  ('ZA2025040205', 'THA68008CPT', 131, 22355.84),
  ('ZA2025021006', 'PIE92012DUR', 190, 20933.45),
  ('ZA2025021006', 'BON90031JNB', 129, 19235.63),
  ('ZA2025021006', 'PIE95013JNB', 158, 9907.82),
  ('ZA2025021006', 'SIP69037JNB', 200, 12434.22),
  ('ZA2024022407', 'LER72033DUR', 151, 10265.43),
  ('ZA2024022407', 'THE62006DUR', 120, 19843.39),
  ('ZA2024022407', 'SIZ94023CPT', 165, 13215.14),
  ('ZA2024022407', 'MAN64001JNB', 93, 18108.49),
  ('ZA2025011108', 'THA68008CPT', 96, 15494.38),
  ('ZA2025011108', 'ELI98026CPT', 109, 9065.39),
  ('ZA2025011108', 'RUA96035CPT', 206, 20157.54),
  ('ZA2025011108', 'PIE95013JNB', 83, 16675.39),
  ('ZA2025092809', 'SIZ94023CPT', 195, 11916.69),
  ('ZA2025092809', 'ELI98026CPT', 204, 15094.26),
  ('ZA2025092809', 'AYA61017CPT', 102, 25097.04),
  ('ZA2025092809', 'PRE85020CPT', 200, 18384.66);

commit;
