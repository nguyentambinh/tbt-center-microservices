-- Sinh tự động bởi tools/seed_data/generate.py, khu vực us. Không sửa tay.
begin;
truncate table project_members, project_contracts, projects, contracts, customers, outbox restart identity cascade;

insert into customers (id, country_code, customer_type, name, contact, address) values
  ('USDN0001', 'US', 'business', 'Anderson Properties LLC', '+1 (713) 555-0185', '157 Park Ave, Houston, TX 77002'),
  ('USCN0002', 'US', 'individual', 'Ryan Lee', '+1 (212) 555-0121', '15 Main St, Houston, TX 77002'),
  ('USCN0003', 'US', 'individual', 'Jennifer Jackson', '+1 (213) 555-0195', '136 Park Ave, New York, NY 10001'),
  ('USDN0004', 'US', 'business', 'Jones Holdings Group', '+1 (312) 555-0153', '1 Main St, New York, NY 10001'),
  ('USCN0005', 'US', 'individual', 'Matthew Martin', '+1 (713) 555-0199', '27 Park Ave, New York, NY 10001'),
  ('USCN0006', 'US', 'individual', 'Emma Lee', '+1 (212) 555-0113', '242 Main St, Chicago, IL 60601'),
  ('USDN0007', 'US', 'business', 'Brown Properties LLC', '+1 (212) 555-0124', '85 Park Ave, Seattle, WA 98101'),
  ('USCN0008', 'US', 'individual', 'James Wilson', '+1 (206) 555-0143', '8 Maple Dr, New York, NY 10001'),
  ('USCN0009', 'US', 'individual', 'James Martinez', '+1 (212) 555-0139', '76 Oak Ave, Houston, TX 77002'),
  ('USDN0010', 'US', 'business', 'Taylor Properties LLC', '+1 (212) 555-0180', '86 Lake St, Los Angeles, CA 90012'),
  ('USCN0011', 'US', 'individual', 'Christopher Martinez', '+1 (206) 555-0157', '212 Lake St, Chicago, IL 60601'),
  ('USCN0012', 'US', 'individual', 'Mary Jones', '+1 (206) 555-0119', '122 Lake St, Los Angeles, CA 90012'),
  ('USDN0013', 'US', 'business', 'Garcia Development Inc.', '+1 (206) 555-0139', '174 Washington Blvd, Los Angeles, CA 90012'),
  ('USCN0014', 'US', 'individual', 'Lauren Anderson', '+1 (713) 555-0146', '17 Main St, Houston, TX 77002'),
  ('USCN0015', 'US', 'individual', 'Michael Miller', '+1 (212) 555-0167', '189 Maple Dr, Los Angeles, CA 90012');

insert into contracts (id, country_code, name, contract_type, start_date, expected_end_date) values
  ('USHD001', 'US', 'Residential house construction', '1', '2024-08-14', '2025-12-26'),
  ('USHD002', 'US', 'Villa construction', '2', '2025-12-03', '2026-08-18'),
  ('USHD003', 'US', 'Office building', '3', '2026-11-02', '2027-04-28'),
  ('USHD004', 'US', 'Warehouse', '4', '2025-05-01', '2026-10-18'),
  ('USHD005', 'US', 'Bridge and road works', '1', '2025-06-08', '2026-10-31'),
  ('USHD006', 'US', 'School renovation', '2', '2025-05-26', '2026-03-02'),
  ('USHD007', 'US', 'Shopping centre fit-out', '3', '2024-02-04', '2024-12-20'),
  ('USHD008', 'US', 'Apartment block', '4', '2024-02-28', '2024-11-20'),
  ('USHD009', 'US', 'Residential house construction', '1', '2024-09-06', '2025-03-16'),
  ('USHD010', 'US', 'Villa construction', '2', '2026-11-09', '2028-02-07');

insert into projects (id, company_id, country_code, customer_id, deposit_amount, expected_acceptance_amount, currency) values
  ('USDA001', 'TBTCHI', 'US', 'USCN0003', 285000.00, 950000.00, 'USD'),
  ('USDA002', 'TBTLAX', 'US', 'USCN0015', 300600.00, 1002000.00, 'USD'),
  ('USDA003', 'TBTNYC', 'US', 'USDN0001', 341400.00, 1138000.00, 'USD'),
  ('USDA004', 'TBTCHI', 'US', 'USCN0002', 253200.00, 844000.00, 'USD'),
  ('USDA005', 'TBTLAX', 'US', 'USCN0002', 352800.00, 1176000.00, 'USD'),
  ('USDA006', 'TBTNYC', 'US', 'USCN0011', 259200.00, 864000.00, 'USD'),
  ('USDA007', 'TBTCHI', 'US', 'USCN0015', 120000.00, 400000.00, 'USD'),
  ('USDA008', 'TBTLAX', 'US', 'USDN0001', 193200.00, 644000.00, 'USD'),
  ('USDA009', 'TBTNYC', 'US', 'USDN0007', 72000.00, 240000.00, 'USD'),
  ('USDA010', 'TBTCHI', 'US', 'USCN0014', 273000.00, 910000.00, 'USD');

insert into project_contracts (id, project_id, contract_id, end_date) values
  ('US2024081400', 'USDA001', 'USHD001', '2025-03-04'),
  ('US2025120301', 'USDA002', 'USHD002', '2026-11-09'),
  ('US2026110202', 'USDA003', 'USHD003', '2027-04-05'),
  ('US2025050103', 'USDA004', 'USHD004', '2026-09-05'),
  ('US2025060804', 'USDA005', 'USHD005', '2026-06-16'),
  ('US2025052605', 'USDA006', 'USHD006', '2026-02-20'),
  ('US2024020406', 'USDA007', 'USHD007', '2025-01-01'),
  ('US2024022807', 'USDA008', 'USHD008', '2025-06-09'),
  ('US2024090608', 'USDA009', 'USHD009', '2025-03-27'),
  ('US2026110909', 'USDA010', 'USHD010', '2027-10-28');

insert into project_members (project_contract_id, employee_id, total_hours, project_salary) values
  ('US2024081400', 'MAR70040NYC', 124, 5363.50),
  ('US2024081400', 'JOS69017CHI', 198, 4613.25),
  ('US2024081400', 'OLI90016NYC', 167, 3209.49),
  ('US2024081400', 'RYA68033LAX', 148, 4614.25),
  ('US2025120301', 'AND65026CHI', 151, 3860.33),
  ('US2025120301', 'LAU64030LAX', 153, 4642.71),
  ('US2025120301', 'AND77011CHI', 217, 3167.67),
  ('US2025120301', 'OLI90016NYC', 207, 3655.48),
  ('US2026110202', 'DAN93006LAX', 94, 3713.85),
  ('US2026110202', 'JAM96007NYC', 139, 2335.72),
  ('US2026110202', 'OLI90016NYC', 180, 3896.06),
  ('US2026110202', 'JOS75037NYC', 140, 4845.62),
  ('US2025050103', 'JOH90020CHI', 123, 4380.50),
  ('US2025050103', 'DAV84038CHI', 101, 3155.57),
  ('US2025050103', 'CHR86015LAX', 124, 3537.00),
  ('US2025050103', 'AND65026CHI', 203, 2474.20),
  ('US2025060804', 'JAM96007NYC', 217, 3166.94),
  ('US2025060804', 'JES99014CHI', 187, 5220.41),
  ('US2025060804', 'JEN61032CHI', 217, 4769.24),
  ('US2025060804', 'DAV76001NYC', 169, 5053.14),
  ('US2025052605', 'DAN91012LAX', 89, 3934.43),
  ('US2025052605', 'WIL85021LAX', 205, 4375.21),
  ('US2025052605', 'LAU75034NYC', 117, 4515.31),
  ('US2025052605', 'DAN93006LAX', 194, 5787.54),
  ('US2024020406', 'MEG73029CHI', 145, 4511.26),
  ('US2024020406', 'MEG77019NYC', 118, 4356.01),
  ('US2024020406', 'ASH84008CHI', 175, 4361.52),
  ('US2024020406', 'DAV76001NYC', 145, 4293.96),
  ('US2024022807', 'CHR86015LAX', 134, 3964.79),
  ('US2024022807', 'MAT96004NYC', 84, 5383.83),
  ('US2024022807', 'LAU92009LAX', 121, 5942.11),
  ('US2024022807', 'MEG77019NYC', 195, 4300.52),
  ('US2024090608', 'EMI73022NYC', 170, 3802.63),
  ('US2024090608', 'LAU75034NYC', 187, 2142.50),
  ('US2024090608', 'DAV76001NYC', 182, 3285.53),
  ('US2024090608', 'JOS75037NYC', 81, 2871.54),
  ('US2026110909', 'LAU92009LAX', 88, 5664.61),
  ('US2026110909', 'MEG73029CHI', 138, 2675.70),
  ('US2026110909', 'JEN61032CHI', 149, 2188.98),
  ('US2026110909', 'AND65026CHI', 84, 5777.84);

commit;
