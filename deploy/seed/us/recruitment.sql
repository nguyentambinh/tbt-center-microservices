-- Sinh tự động bởi tools/seed_data/generate.py, khu vực us. Không sửa tay.
begin;
truncate table candidate_status_history, candidate_documents, cv_summaries, candidate_import_rows, candidate_imports, candidates, outbox restart identity cascade;

insert into candidates (id, country_code, full_name, email, phone, applied_position, status, source, cv_object_key, consent_ai, created_at) values
  ('c64087ec-cb53-4d88-9a27-2248b898eb60', 'US', 'Ryan Anderson', 'ryan.anderson.0@example.com', '+1 (713) 555-0198', 'Structural Engineer', 'rejected', 'self', null, true, '2026-10-01 09:00:00'),
  ('6d8e0264-bc25-45f5-9b84-6d77efbef085', 'US', 'Daniel Davis', 'daniel.davis.1@example.com', '+1 (312) 555-0172', 'Accountant', 'analyzed', 'self', null, true, '2026-10-05 10:00:00'),
  ('f9b685c5-9143-483d-bd4d-f36e461ff633', 'US', 'Emily Jones', 'emily.jones.2@example.com', '+1 (213) 555-0187', 'Administrative Assistant', 'submitted', 'self', null, true, '2026-07-14 12:00:00'),
  ('9a17cc74-427c-4171-8434-7469ea893ed2', 'US', 'Mary Miller', 'mary.miller.3@example.com', '+1 (213) 555-0125', 'Civil Engineer', 'rejected', 'self', null, true, '2026-09-04 10:00:00'),
  ('10b2ea28-1a6a-4dfd-badd-40f753a27bec', 'US', 'Rachel Davis', 'rachel.davis.4@example.com', '+1 (713) 555-0150', 'Site Supervisor', 'rejected', 'self', null, true, '2026-10-07 11:00:00'),
  ('c1e7af67-6e8c-4c50-9510-fa9ef879bfa7', 'US', 'Andrew Johnson', 'andrew.johnson.5@example.com', '+1 (213) 555-0181', 'Accountant', 'analyzed', 'self', null, true, '2026-10-12 17:00:00'),
  ('555c183f-9feb-4c04-bee1-55f054b482f3', 'US', 'Michael White', 'michael.white.6@example.com', '+1 (713) 555-0165', 'HR Specialist', 'screening', 'self', null, true, '2026-08-02 16:00:00'),
  ('19ff2067-f1f1-4752-a171-e1d1b7d47829', 'US', 'James Taylor', 'james.taylor.7@example.com', '+1 (212) 555-0116', 'Project Manager', 'submitted', 'self', null, true, '2026-09-09 16:00:00'),
  ('ed8c221f-b474-42c8-96b3-1644551a87d3', 'US', 'Matthew Williams', 'matthew.williams.8@example.com', '+1 (713) 555-0136', 'Administrative Assistant', 'interview', 'self', null, true, '2026-07-01 11:00:00'),
  ('8a759dd7-f7bb-4b49-a626-c67603ded5ba', 'US', 'Megan White', 'megan.white.9@example.com', '+1 (312) 555-0152', 'Civil Engineer', 'interview', 'self', null, true, '2026-10-10 09:00:00');

insert into candidate_status_history (candidate_id, status, note, changed_by, changed_at) values
  ('c64087ec-cb53-4d88-9a27-2248b898eb60', 'submitted', null, 'system', '2026-10-01 09:00:00'),
  ('c64087ec-cb53-4d88-9a27-2248b898eb60', 'analyzed', null, 'system', '2026-10-06 16:00:00'),
  ('c64087ec-cb53-4d88-9a27-2248b898eb60', 'rejected', null, 'hr.us', '2026-10-12 00:00:00'),
  ('6d8e0264-bc25-45f5-9b84-6d77efbef085', 'submitted', null, 'system', '2026-10-05 10:00:00'),
  ('6d8e0264-bc25-45f5-9b84-6d77efbef085', 'analyzed', null, 'system', '2026-10-08 12:00:00'),
  ('f9b685c5-9143-483d-bd4d-f36e461ff633', 'submitted', null, 'system', '2026-07-14 12:00:00'),
  ('9a17cc74-427c-4171-8434-7469ea893ed2', 'submitted', null, 'system', '2026-09-04 10:00:00'),
  ('9a17cc74-427c-4171-8434-7469ea893ed2', 'analyzed', null, 'system', '2026-09-08 15:00:00'),
  ('9a17cc74-427c-4171-8434-7469ea893ed2', 'rejected', null, 'hr.us', '2026-09-13 17:00:00'),
  ('10b2ea28-1a6a-4dfd-badd-40f753a27bec', 'submitted', null, 'system', '2026-10-07 11:00:00'),
  ('10b2ea28-1a6a-4dfd-badd-40f753a27bec', 'analyzed', null, 'system', '2026-10-10 15:00:00'),
  ('10b2ea28-1a6a-4dfd-badd-40f753a27bec', 'rejected', null, 'hr.us', '2026-10-11 23:00:00'),
  ('c1e7af67-6e8c-4c50-9510-fa9ef879bfa7', 'submitted', null, 'system', '2026-10-12 17:00:00'),
  ('c1e7af67-6e8c-4c50-9510-fa9ef879bfa7', 'analyzed', null, 'system', '2026-10-15 00:00:00'),
  ('555c183f-9feb-4c04-bee1-55f054b482f3', 'submitted', null, 'system', '2026-08-02 16:00:00'),
  ('555c183f-9feb-4c04-bee1-55f054b482f3', 'analyzed', null, 'system', '2026-08-04 00:00:00'),
  ('555c183f-9feb-4c04-bee1-55f054b482f3', 'screening', null, 'hr.us', '2026-08-10 05:00:00'),
  ('19ff2067-f1f1-4752-a171-e1d1b7d47829', 'submitted', null, 'system', '2026-09-09 16:00:00'),
  ('ed8c221f-b474-42c8-96b3-1644551a87d3', 'submitted', null, 'system', '2026-07-01 11:00:00'),
  ('ed8c221f-b474-42c8-96b3-1644551a87d3', 'analyzed', null, 'system', '2026-07-04 15:00:00'),
  ('ed8c221f-b474-42c8-96b3-1644551a87d3', 'screening', null, 'hr.us', '2026-07-05 21:00:00'),
  ('ed8c221f-b474-42c8-96b3-1644551a87d3', 'interview', null, 'hr.us', '2026-07-08 04:00:00'),
  ('8a759dd7-f7bb-4b49-a626-c67603ded5ba', 'submitted', null, 'system', '2026-10-10 09:00:00'),
  ('8a759dd7-f7bb-4b49-a626-c67603ded5ba', 'analyzed', null, 'system', '2026-10-12 11:00:00'),
  ('8a759dd7-f7bb-4b49-a626-c67603ded5ba', 'screening', null, 'hr.us', '2026-10-13 13:00:00'),
  ('8a759dd7-f7bb-4b49-a626-c67603ded5ba', 'interview', null, 'hr.us', '2026-10-17 16:00:00');

commit;
