-- Sinh tự động bởi tools/seed_data/generate.py, khu vực za. Không sửa tay.
begin;
truncate table candidate_status_history, candidate_documents, cv_summaries, candidate_import_rows, candidate_imports, candidates, outbox restart identity cascade;

insert into candidates (id, country_code, full_name, email, phone, applied_position, status, source, cv_object_key, consent_ai, created_at) values
  ('00eff0c2-e69e-4eae-9f4e-184b4d110369', 'ZA', 'Themba Venter', 'themba.venter.0@example.com', '+27 82 581 3057', 'Project Manager', 'rejected', 'self', null, true, '2026-08-02 08:00:00'),
  ('bf9e43b4-62db-452b-993f-1c774660e1fe', 'ZA', 'Anika Molefe', 'anika.molefe.1@example.com', '+27 82 279 1351', 'Accountant', 'rejected', 'self', null, true, '2026-10-14 17:00:00'),
  ('d4580d28-7039-4efe-8b61-5690f4b766de', 'ZA', 'Bongani Zulu', 'bongani.zulu.2@example.com', '+27 82 418 8397', 'Civil Engineer', 'screening', 'self', null, true, '2026-10-09 17:00:00'),
  ('d0dceb73-a34d-4d98-ad4b-1961f7a971ac', 'ZA', 'Palesa Naidoo', 'palesa.naidoo.3@example.com', '+27 83 424 9132', 'Safety Officer', 'interview', 'self', null, true, '2026-07-12 16:00:00'),
  ('f7286d8e-5f39-44bf-b9b3-cc6f3276dddb', 'ZA', 'Sipho Mahlangu', 'sipho.mahlangu.4@example.com', '+27 82 875 5801', 'Site Supervisor', 'screening', 'self', null, true, '2026-06-06 10:00:00'),
  ('0609ff59-bd84-4af5-833b-c3752b521165', 'ZA', 'Pieter Smith', 'pieter.smith.5@example.com', '+27 82 658 6624', 'Safety Officer', 'analyzed', 'self', null, true, '2026-09-03 15:00:00'),
  ('120fa55f-4f78-4090-ad9d-d673006e1129', 'ZA', 'Lwazi Mthembu', 'lwazi.mthembu.6@example.com', '+27 72 664 6134', 'Site Supervisor', 'interview', 'self', null, true, '2026-08-02 15:00:00'),
  ('469750b9-7a89-4705-a9f5-534d392e6d1f', 'ZA', 'Elize Zulu', 'elize.zulu.7@example.com', '+27 83 604 9116', 'Accountant', 'submitted', 'self', null, true, '2026-06-02 14:00:00'),
  ('14f36a78-3f8f-4e7d-9d1e-34e1aa5bf6d3', 'ZA', 'Lerato Pillay', 'lerato.pillay.8@example.com', '+27 72 106 6431', 'Structural Engineer', 'screening', 'self', null, true, '2026-06-09 14:00:00'),
  ('fc8c7fa3-e06d-4215-af5e-3f8f3db1378e', 'ZA', 'Sipho Pillay', 'sipho.pillay.9@example.com', '+27 72 968 2441', 'Project Manager', 'analyzed', 'self', null, true, '2026-10-13 08:00:00');

insert into candidate_status_history (candidate_id, status, note, changed_by, changed_at) values
  ('00eff0c2-e69e-4eae-9f4e-184b4d110369', 'submitted', null, 'system', '2026-08-02 08:00:00'),
  ('00eff0c2-e69e-4eae-9f4e-184b4d110369', 'analyzed', null, 'system', '2026-08-06 14:00:00'),
  ('00eff0c2-e69e-4eae-9f4e-184b4d110369', 'rejected', null, 'hr.za', '2026-08-10 19:00:00'),
  ('bf9e43b4-62db-452b-993f-1c774660e1fe', 'submitted', null, 'system', '2026-10-14 17:00:00'),
  ('bf9e43b4-62db-452b-993f-1c774660e1fe', 'analyzed', null, 'system', '2026-10-15 23:00:00'),
  ('bf9e43b4-62db-452b-993f-1c774660e1fe', 'rejected', null, 'hr.za', '2026-10-22 07:00:00'),
  ('d4580d28-7039-4efe-8b61-5690f4b766de', 'submitted', null, 'system', '2026-10-09 17:00:00'),
  ('d4580d28-7039-4efe-8b61-5690f4b766de', 'analyzed', null, 'system', '2026-10-15 23:00:00'),
  ('d4580d28-7039-4efe-8b61-5690f4b766de', 'screening', null, 'hr.za', '2026-10-21 02:00:00'),
  ('d0dceb73-a34d-4d98-ad4b-1961f7a971ac', 'submitted', null, 'system', '2026-07-12 16:00:00'),
  ('d0dceb73-a34d-4d98-ad4b-1961f7a971ac', 'analyzed', null, 'system', '2026-07-16 17:00:00'),
  ('d0dceb73-a34d-4d98-ad4b-1961f7a971ac', 'screening', null, 'hr.za', '2026-07-18 19:00:00'),
  ('d0dceb73-a34d-4d98-ad4b-1961f7a971ac', 'interview', null, 'hr.za', '2026-07-21 21:00:00'),
  ('f7286d8e-5f39-44bf-b9b3-cc6f3276dddb', 'submitted', null, 'system', '2026-06-06 10:00:00'),
  ('f7286d8e-5f39-44bf-b9b3-cc6f3276dddb', 'analyzed', null, 'system', '2026-06-11 11:00:00'),
  ('f7286d8e-5f39-44bf-b9b3-cc6f3276dddb', 'screening', null, 'hr.za', '2026-06-15 12:00:00'),
  ('0609ff59-bd84-4af5-833b-c3752b521165', 'submitted', null, 'system', '2026-09-03 15:00:00'),
  ('0609ff59-bd84-4af5-833b-c3752b521165', 'analyzed', null, 'system', '2026-09-06 17:00:00'),
  ('120fa55f-4f78-4090-ad9d-d673006e1129', 'submitted', null, 'system', '2026-08-02 15:00:00'),
  ('120fa55f-4f78-4090-ad9d-d673006e1129', 'analyzed', null, 'system', '2026-08-04 21:00:00'),
  ('120fa55f-4f78-4090-ad9d-d673006e1129', 'screening', null, 'hr.za', '2026-08-09 01:00:00'),
  ('120fa55f-4f78-4090-ad9d-d673006e1129', 'interview', null, 'hr.za', '2026-08-14 09:00:00'),
  ('469750b9-7a89-4705-a9f5-534d392e6d1f', 'submitted', null, 'system', '2026-06-02 14:00:00'),
  ('14f36a78-3f8f-4e7d-9d1e-34e1aa5bf6d3', 'submitted', null, 'system', '2026-06-09 14:00:00'),
  ('14f36a78-3f8f-4e7d-9d1e-34e1aa5bf6d3', 'analyzed', null, 'system', '2026-06-14 16:00:00'),
  ('14f36a78-3f8f-4e7d-9d1e-34e1aa5bf6d3', 'screening', null, 'hr.za', '2026-06-16 20:00:00'),
  ('fc8c7fa3-e06d-4215-af5e-3f8f3db1378e', 'submitted', null, 'system', '2026-10-13 08:00:00'),
  ('fc8c7fa3-e06d-4215-af5e-3f8f3db1378e', 'analyzed', null, 'system', '2026-10-18 16:00:00');

commit;
