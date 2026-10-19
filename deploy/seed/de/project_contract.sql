-- Sinh tự động bởi tools/seed_data/generate.py, khu vực de. Không sửa tay.
begin;
truncate table project_members, project_contracts, projects, contracts, customers, outbox restart identity cascade;

insert into customers (id, country_code, customer_type, name, contact, address) values
  ('DEDN0001', 'DE', 'business', 'Krüger Projektentwicklung GmbH', '+49 157 7540763', 'Goethestraße 232, 80331 München'),
  ('DECN0002', 'DE', 'individual', 'Paul Schmidt', '+49 153 9526846', 'Gartenstraße 63, 20095 Hamburg'),
  ('DECN0003', 'DE', 'individual', 'Jonas Becker', '+49 156 1091615', 'Hauptstraße 187, 10115 Berlin'),
  ('DEDN0004', 'DE', 'business', 'Wagner Projektentwicklung GmbH', '+49 153 3733886', 'Hauptstraße 139, 10115 Berlin'),
  ('DECN0005', 'DE', 'individual', 'Andreas Richter', '+49 151 2677200', 'Schillerstraße 149, 80331 München'),
  ('DECN0006', 'DE', 'individual', 'Marie Krüger', '+49 151 7342317', 'Goethestraße 190, 20095 Hamburg'),
  ('DEDN0007', 'DE', 'business', 'Fischer Wohnbau AG', '+49 154 9260446', 'Bahnhofstraße 169, 50667 Köln'),
  ('DECN0008', 'DE', 'individual', 'Maximilian Zimmermann', '+49 155 3497168', 'Lindenweg 16, 60311 Frankfurt am Main'),
  ('DECN0009', 'DE', 'individual', 'Leon Müller', '+49 156 7763948', 'Gartenstraße 16, 60311 Frankfurt am Main'),
  ('DEDN0010', 'DE', 'business', 'Müller Wohnbau AG', '+49 151 6673481', 'Goethestraße 120, 50667 Köln'),
  ('DECN0011', 'DE', 'individual', 'Anna Schulz', '+49 156 4130168', 'Goethestraße 114, 80331 München'),
  ('DECN0012', 'DE', 'individual', 'Paul Müller', '+49 151 8731025', 'Hauptstraße 8, 80331 München'),
  ('DEDN0013', 'DE', 'business', 'Schulz Projektentwicklung GmbH', '+49 156 6951477', 'Gartenstraße 125, 20095 Hamburg'),
  ('DECN0014', 'DE', 'individual', 'Felix Schröder', '+49 155 2613016', 'Bahnhofstraße 1, 60311 Frankfurt am Main'),
  ('DECN0015', 'DE', 'individual', 'Lea Klein', '+49 156 9096108', 'Goethestraße 151, 80331 München');

insert into contracts (id, country_code, name, contract_type, start_date, expected_end_date) values
  ('DEHD001', 'DE', 'Neubau Einfamilienhaus', '1', '2024-06-05', '2024-12-11'),
  ('DEHD002', 'DE', 'Neubau Villa', '2', '2026-11-27', '2028-01-17'),
  ('DEHD003', 'DE', 'Bürogebäude', '3', '2026-05-14', '2026-10-23'),
  ('DEHD004', 'DE', 'Lagerhalle', '4', '2026-07-27', '2027-03-08'),
  ('DEHD005', 'DE', 'Brücken- und Straßenbau', '1', '2025-11-15', '2026-11-26'),
  ('DEHD006', 'DE', 'Schulsanierung', '2', '2025-11-09', '2027-04-06'),
  ('DEHD007', 'DE', 'Ausbau Einkaufszentrum', '3', '2026-03-14', '2026-09-01'),
  ('DEHD008', 'DE', 'Mehrfamilienhaus', '4', '2026-10-06', '2027-09-12'),
  ('DEHD009', 'DE', 'Neubau Einfamilienhaus', '1', '2025-07-07', '2026-08-16'),
  ('DEHD010', 'DE', 'Neubau Villa', '2', '2026-07-09', '2027-12-24');

insert into projects (id, company_id, country_code, customer_id, deposit_amount, expected_acceptance_amount, currency) values
  ('DEDA001', 'TBTBER', 'DE', 'DECN0012', 229050.00, 763500.00, 'EUR'),
  ('DEDA002', 'TBTBER', 'DE', 'DECN0015', 119250.00, 397500.00, 'EUR'),
  ('DEDA003', 'TBTMUC', 'DE', 'DECN0015', 158850.00, 529500.00, 'EUR'),
  ('DEDA004', 'TBTMUC', 'DE', 'DECN0005', 204750.00, 682500.00, 'EUR'),
  ('DEDA005', 'TBTHAM', 'DE', 'DECN0008', 178200.00, 594000.00, 'EUR'),
  ('DEDA006', 'TBTHAM', 'DE', 'DECN0011', 170100.00, 567000.00, 'EUR'),
  ('DEDA007', 'TBTBER', 'DE', 'DECN0011', 258300.00, 861000.00, 'EUR'),
  ('DEDA008', 'TBTBER', 'DE', 'DECN0005', 139500.00, 465000.00, 'EUR'),
  ('DEDA009', 'TBTHAM', 'DE', 'DECN0003', 108450.00, 361500.00, 'EUR'),
  ('DEDA010', 'TBTBER', 'DE', 'DEDN0001', 36000.00, 120000.00, 'EUR');

insert into project_contracts (id, project_id, contract_id, end_date) values
  ('DE2024060500', 'DEDA001', 'DEHD001', '2026-01-12'),
  ('DE2026112701', 'DEDA002', 'DEHD002', '2027-11-14'),
  ('DE2026051402', 'DEDA003', 'DEHD003', '2027-04-01'),
  ('DE2026072703', 'DEDA004', 'DEHD004', '2027-02-09'),
  ('DE2025111504', 'DEDA005', 'DEHD005', '2026-10-26'),
  ('DE2025110905', 'DEDA006', 'DEHD006', '2026-10-10'),
  ('DE2026031406', 'DEDA007', 'DEHD007', '2027-06-03'),
  ('DE2026100607', 'DEDA008', 'DEHD008', '2027-11-21'),
  ('DE2025070708', 'DEDA009', 'DEHD009', '2026-03-23'),
  ('DE2026070909', 'DEDA010', 'DEHD010', '2027-02-20');

insert into project_members (project_contract_id, employee_id, total_hours, project_salary) values
  ('DE2024060500', 'MAR99022BER', 206, 3279.93),
  ('DE2024060500', 'LEO72014MUC', 132, 2467.62),
  ('DE2024060500', 'LEA89029MUC', 171, 1500.43),
  ('DE2024060500', 'TOB99017MUC', 214, 3887.97),
  ('DE2026112701', 'MIC89033HAM', 111, 1660.87),
  ('DE2026112701', 'NIN93012HAM', 124, 4111.93),
  ('DE2026112701', 'CLA92026MUC', 208, 2059.92),
  ('DE2026112701', 'ANN65010BER', 182, 3669.54),
  ('DE2026051402', 'TOB83036HAM', 152, 3965.21),
  ('DE2026051402', 'TOB99017MUC', 209, 4489.71),
  ('DE2026051402', 'HAN73009HAM', 99, 3674.95),
  ('DE2026051402', 'AND90006HAM', 153, 1508.24),
  ('DE2026072703', 'LUK81019BER', 92, 2505.79),
  ('DE2026072703', 'ANN91025BER', 119, 2384.19),
  ('DE2026072703', 'JAN82016BER', 215, 3405.21),
  ('DE2026072703', 'MIC64011MUC', 166, 3230.37),
  ('DE2025111504', 'LEA89029MUC', 174, 3769.25),
  ('DE2025111504', 'MIC89033HAM', 99, 3793.82),
  ('DE2025111504', 'LEN84001BER', 209, 3829.51),
  ('DE2025111504', 'JON90024HAM', 186, 4369.11),
  ('DE2025110905', 'JAN91020MUC', 139, 2842.66),
  ('DE2025110905', 'ANN91025BER', 207, 3192.93),
  ('DE2025110905', 'LEO95032MUC', 218, 3294.00),
  ('DE2025110905', 'KAT93007BER', 144, 4365.00),
  ('DE2026031406', 'JON90024HAM', 205, 3307.24),
  ('DE2026031406', 'FEL92004BER', 110, 1531.43),
  ('DE2026031406', 'JAN82016BER', 194, 4473.04),
  ('DE2026031406', 'TOB99017MUC', 110, 3146.28),
  ('DE2026100607', 'KAT93007BER', 146, 2808.21),
  ('DE2026100607', 'SOP94015HAM', 171, 2557.13),
  ('DE2026100607', 'LUK75021HAM', 219, 4328.63),
  ('DE2026100607', 'JON83038MUC', 112, 4322.71),
  ('DE2025070708', 'TOB99017MUC', 103, 1965.68),
  ('DE2025070708', 'FEL80003HAM', 181, 2699.52),
  ('DE2025070708', 'KAT76034BER', 123, 3962.78),
  ('DE2025070708', 'SOP94015HAM', 137, 2173.12),
  ('DE2026070909', 'LUK81019BER', 92, 1979.04),
  ('DE2026070909', 'LEN71008MUC', 175, 3807.90),
  ('DE2026070909', 'LEA89029MUC', 201, 2578.52),
  ('DE2026070909', 'JAN94039HAM', 162, 3211.30);

commit;
