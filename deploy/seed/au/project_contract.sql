-- Sinh tự động bởi tools/seed_data/generate.py, khu vực au. Không sửa tay.
begin;
truncate table project_members, project_contracts, projects, contracts, customers, outbox restart identity cascade;

insert into customers (id, country_code, customer_type, name, contact, address) values
  ('AUDN0001', 'AU', 'business', 'Walker Holdings Pty Ltd', '+61 480 101 680', '125 Victoria Rd, Adelaide SA 5000'),
  ('AUCN0002', 'AU', 'individual', 'Noah Thomas', '+61 492 493 783', '133 Beach Rd, Adelaide SA 5000'),
  ('AUCN0003', 'AU', 'individual', 'Chloe Lee', '+61 478 915 477', '235 Victoria Rd, Brisbane QLD 4000'),
  ('AUDN0004', 'AU', 'business', 'Jones Developments Pty Ltd', '+61 430 155 232', '209 Victoria Rd, Perth WA 6000'),
  ('AUCN0005', 'AU', 'individual', 'Cooper Robinson', '+61 432 913 953', '125 King St, Perth WA 6000'),
  ('AUCN0006', 'AU', 'individual', 'Isla Taylor', '+61 448 798 738', '116 High St, Brisbane QLD 4000'),
  ('AUDN0007', 'AU', 'business', 'Lee Property Group', '+61 469 992 427', '159 King St, Brisbane QLD 4000'),
  ('AUCN0008', 'AU', 'individual', 'Grace Taylor', '+61 452 795 744', '144 Victoria Rd, Sydney NSW 2000'),
  ('AUCN0009', 'AU', 'individual', 'Charlotte Taylor', '+61 447 938 115', '22 Beach Rd, Melbourne VIC 3000'),
  ('AUDN0010', 'AU', 'business', 'Jones Holdings Pty Ltd', '+61 472 959 834', '151 George St, Melbourne VIC 3000'),
  ('AUCN0011', 'AU', 'individual', 'Ethan Anderson', '+61 417 877 991', '193 Station St, Brisbane QLD 4000'),
  ('AUCN0012', 'AU', 'individual', 'Mitchell Harris', '+61 439 585 251', '121 Beach Rd, Brisbane QLD 4000'),
  ('AUDN0013', 'AU', 'business', 'King Developments Pty Ltd', '+61 472 384 653', '49 George St, Sydney NSW 2000'),
  ('AUCN0014', 'AU', 'individual', 'James Nguyen', '+61 469 176 709', '20 High St, Sydney NSW 2000'),
  ('AUCN0015', 'AU', 'individual', 'Emily White', '+61 455 467 429', '190 Station St, Brisbane QLD 4000');

insert into contracts (id, country_code, name, contract_type, start_date, expected_end_date) values
  ('AUHD001', 'AU', 'Residential house construction', '1', '2026-10-24', '2027-11-26'),
  ('AUHD002', 'AU', 'Villa construction', '2', '2026-12-06', '2027-11-02'),
  ('AUHD003', 'AU', 'Office building', '3', '2024-09-28', '2026-01-03'),
  ('AUHD004', 'AU', 'Warehouse', '4', '2026-07-14', '2027-04-23'),
  ('AUHD005', 'AU', 'Bridge and road works', '1', '2024-02-28', '2024-11-16'),
  ('AUHD006', 'AU', 'School renovation', '2', '2024-02-04', '2024-10-15'),
  ('AUHD007', 'AU', 'Shopping centre fit-out', '3', '2025-09-14', '2026-05-31'),
  ('AUHD008', 'AU', 'Apartment block', '4', '2024-06-06', '2025-07-11'),
  ('AUHD009', 'AU', 'Residential house construction', '1', '2025-01-04', '2025-10-12'),
  ('AUHD010', 'AU', 'Villa construction', '2', '2024-10-26', '2025-03-27');

insert into projects (id, company_id, country_code, customer_id, deposit_amount, expected_acceptance_amount, currency) values
  ('AUDA001', 'TBTMEL', 'AU', 'AUCN0003', 127140.00, 423800.00, 'AUD'),
  ('AUDA002', 'TBTMEL', 'AU', 'AUCN0003', 107640.00, 358800.00, 'AUD'),
  ('AUDA003', 'TBTMEL', 'AU', 'AUCN0014', 62400.00, 208000.00, 'AUD'),
  ('AUDA004', 'TBTBNE', 'AU', 'AUCN0006', 203580.00, 678600.00, 'AUD'),
  ('AUDA005', 'TBTSYD', 'AU', 'AUCN0005', 295620.00, 985400.00, 'AUD'),
  ('AUDA006', 'TBTBNE', 'AU', 'AUDN0013', 153660.00, 512200.00, 'AUD'),
  ('AUDA007', 'TBTBNE', 'AU', 'AUCN0012', 138840.00, 462800.00, 'AUD'),
  ('AUDA008', 'TBTSYD', 'AU', 'AUCN0002', 345540.00, 1151800.00, 'AUD'),
  ('AUDA009', 'TBTBNE', 'AU', 'AUCN0012', 138840.00, 462800.00, 'AUD'),
  ('AUDA010', 'TBTBNE', 'AU', 'AUDN0013', 209820.00, 699400.00, 'AUD');

insert into project_contracts (id, project_id, contract_id, end_date) values
  ('AU2026102400', 'AUDA001', 'AUHD001', '2028-03-09'),
  ('AU2026120601', 'AUDA002', 'AUHD002', '2028-04-27'),
  ('AU2024092802', 'AUDA003', 'AUHD003', '2026-01-27'),
  ('AU2026071403', 'AUDA004', 'AUHD004', '2027-01-09'),
  ('AU2024022804', 'AUDA005', 'AUHD005', '2025-06-27'),
  ('AU2024020405', 'AUDA006', 'AUHD006', '2025-05-12'),
  ('AU2025091406', 'AUDA007', 'AUHD007', '2026-06-11'),
  ('AU2024060607', 'AUDA008', 'AUHD008', '2025-06-14'),
  ('AU2025010408', 'AUDA009', 'AUHD009', '2025-08-16'),
  ('AU2024102609', 'AUDA010', 'AUHD010', '2025-08-30');

insert into project_members (project_contract_id, employee_id, total_hours, project_salary) values
  ('AU2026102400', 'RUB78033BNE', 110, 4094.81),
  ('AU2026102400', 'EMI97030BNE', 100, 4763.16),
  ('AU2026102400', 'COO86009BNE', 194, 4146.96),
  ('AU2026102400', 'NOA82023MEL', 126, 4403.16),
  ('AU2026120601', 'WIL97007SYD', 206, 5243.79),
  ('AU2026120601', 'LIA72022SYD', 179, 3183.68),
  ('AU2026120601', 'NOA82006BNE', 174, 5589.94),
  ('AU2026120601', 'GRA92014MEL', 130, 6434.13),
  ('AU2024092802', 'LIA78027BNE', 142, 6249.94),
  ('AU2024092802', 'SOP89012BNE', 87, 6489.50),
  ('AU2024092802', 'WIL97007SYD', 130, 4525.14),
  ('AU2024092802', 'AVA65032MEL', 145, 7420.90),
  ('AU2026071403', 'MIT79019SYD', 180, 6780.68),
  ('AU2026071403', 'JAM84002MEL', 216, 4310.79),
  ('AU2026071403', 'WIL97007SYD', 205, 4023.61),
  ('AU2026071403', 'NOA87020MEL', 107, 7290.23),
  ('AU2024022804', 'OLI84015BNE', 107, 5551.53),
  ('AU2024022804', 'THO71039BNE', 150, 4026.74),
  ('AU2024022804', 'SOP97013SYD', 132, 5880.74),
  ('AU2024022804', 'SOP89012BNE', 122, 5185.84),
  ('AU2024020405', 'NOA87020MEL', 102, 3546.45),
  ('AU2024020405', 'COO86009BNE', 220, 4234.38),
  ('AU2024020405', 'OLI86029MEL', 119, 5731.11),
  ('AU2024020405', 'NOA82006BNE', 84, 4963.21),
  ('AU2025091406', 'OLI92035MEL', 140, 7629.63),
  ('AU2025091406', 'WIL97007SYD', 162, 6449.80),
  ('AU2025091406', 'MAT75040SYD', 133, 5928.92),
  ('AU2025091406', 'EMI92026MEL', 177, 6030.19),
  ('AU2024060607', 'OLI92035MEL', 135, 6490.22),
  ('AU2024060607', 'COO72038MEL', 94, 4963.57),
  ('AU2024060607', 'NOA82023MEL', 165, 7020.55),
  ('AU2024060607', 'ISL73037SYD', 205, 3305.89),
  ('AU2025010408', 'MAT77011MEL', 170, 3365.77),
  ('AU2025010408', 'MAT75040SYD', 91, 3114.26),
  ('AU2025010408', 'MIT79019SYD', 219, 3508.21),
  ('AU2025010408', 'SOP89012BNE', 117, 6972.79),
  ('AU2024102609', 'ISL73037SYD', 109, 4173.28),
  ('AU2024102609', 'MAT75040SYD', 82, 7339.45),
  ('AU2024102609', 'WIL67001SYD', 114, 4883.54),
  ('AU2024102609', 'GRA92014MEL', 100, 5102.22);

commit;
