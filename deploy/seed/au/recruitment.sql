-- Sinh tự động bởi tools/seed_data/generate.py, khu vực au. Không sửa tay.
begin;
truncate table candidate_status_history, candidate_documents, cv_summaries, candidate_import_rows, candidate_imports, candidates, outbox restart identity cascade;

insert into candidates (id, country_code, full_name, email, phone, applied_position, status, source, cv_object_key, consent_ai, created_at) values
  ('ab03b40c-5fc0-4cca-be29-11b2c4b13210', 'AU', 'William Wilson', 'william.wilson.0@example.com', '+61 487 891 827', 'Administrative Assistant', 'interview', 'self', null, true, '2026-06-06 16:00:00'),
  ('4b0cf0aa-b39d-4c7c-89c7-e36d94ab29d9', 'AU', 'Mitchell Williams', 'mitchell.williams.1@example.com', '+61 424 103 194', 'Civil Engineer', 'offered', 'self', null, true, '2026-06-14 15:00:00'),
  ('5f525bec-adbb-498e-a4b6-75559a0011e1', 'AU', 'Ruby Williams', 'ruby.williams.2@example.com', '+61 423 541 408', 'Administrative Assistant', 'rejected', 'self', null, true, '2026-06-06 17:00:00'),
  ('da859750-ba07-447b-9592-a0572bc265d9', 'AU', 'Grace King', 'grace.king.3@example.com', '+61 473 487 155', 'Structural Engineer', 'analyzed', 'self', null, true, '2026-07-04 11:00:00'),
  ('d2387e14-f5c7-4b23-a949-fb88aa60bfa7', 'AU', 'Ethan Johnson', 'ethan.johnson.4@example.com', '+61 448 165 679', 'Structural Engineer', 'rejected', 'self', null, true, '2026-07-05 11:00:00'),
  ('b2c91120-3b2a-4875-801b-689ff2e43b9c', 'AU', 'Jack Lee', 'jack.lee.5@example.com', '+61 457 837 177', 'Administrative Assistant', 'interview', 'self', null, true, '2026-09-04 12:00:00'),
  ('92c614a8-9960-421b-a854-28d17cb68a56', 'AU', 'Emily Williams', 'emily.williams.6@example.com', '+61 467 600 715', 'Accountant', 'screening', 'self', null, true, '2026-07-14 12:00:00'),
  ('4cb32c78-14b0-427c-b444-0d07e5fa62bc', 'AU', 'Grace Wilson', 'grace.wilson.7@example.com', '+61 414 449 525', 'Accountant', 'analyzed', 'self', null, true, '2026-09-06 10:00:00'),
  ('5dfc8f0b-23ae-466d-b40f-efaddb0b39b8', 'AU', 'Matilda Williams', 'matilda.williams.8@example.com', '+61 442 447 624', 'Site Supervisor', 'rejected', 'self', null, true, '2026-10-08 09:00:00'),
  ('b7dc7788-b5e9-46df-9dba-c9fc1756c8bd', 'AU', 'Emily Kelly', 'emily.kelly.9@example.com', '+61 477 714 304', 'Administrative Assistant', 'submitted', 'self', null, true, '2026-06-05 08:00:00');

insert into candidate_status_history (candidate_id, status, note, changed_by, changed_at) values
  ('ab03b40c-5fc0-4cca-be29-11b2c4b13210', 'submitted', null, 'system', '2026-06-06 16:00:00'),
  ('ab03b40c-5fc0-4cca-be29-11b2c4b13210', 'analyzed', null, 'system', '2026-06-08 00:00:00'),
  ('ab03b40c-5fc0-4cca-be29-11b2c4b13210', 'screening', null, 'hr.au', '2026-06-14 04:00:00'),
  ('ab03b40c-5fc0-4cca-be29-11b2c4b13210', 'interview', null, 'hr.au', '2026-06-20 09:00:00'),
  ('4b0cf0aa-b39d-4c7c-89c7-e36d94ab29d9', 'submitted', null, 'system', '2026-06-14 15:00:00'),
  ('4b0cf0aa-b39d-4c7c-89c7-e36d94ab29d9', 'analyzed', null, 'system', '2026-06-18 23:00:00'),
  ('4b0cf0aa-b39d-4c7c-89c7-e36d94ab29d9', 'screening', null, 'hr.au', '2026-06-20 07:00:00'),
  ('4b0cf0aa-b39d-4c7c-89c7-e36d94ab29d9', 'interview', null, 'hr.au', '2026-06-22 09:00:00'),
  ('4b0cf0aa-b39d-4c7c-89c7-e36d94ab29d9', 'offered', null, 'hr.au', '2026-06-25 16:00:00'),
  ('5f525bec-adbb-498e-a4b6-75559a0011e1', 'submitted', null, 'system', '2026-06-06 17:00:00'),
  ('5f525bec-adbb-498e-a4b6-75559a0011e1', 'analyzed', null, 'system', '2026-06-09 18:00:00'),
  ('5f525bec-adbb-498e-a4b6-75559a0011e1', 'rejected', null, 'hr.au', '2026-06-10 21:00:00'),
  ('da859750-ba07-447b-9592-a0572bc265d9', 'submitted', null, 'system', '2026-07-04 11:00:00'),
  ('da859750-ba07-447b-9592-a0572bc265d9', 'analyzed', null, 'system', '2026-07-06 16:00:00'),
  ('d2387e14-f5c7-4b23-a949-fb88aa60bfa7', 'submitted', null, 'system', '2026-07-05 11:00:00'),
  ('d2387e14-f5c7-4b23-a949-fb88aa60bfa7', 'analyzed', null, 'system', '2026-07-09 18:00:00'),
  ('d2387e14-f5c7-4b23-a949-fb88aa60bfa7', 'rejected', null, 'hr.au', '2026-07-10 22:00:00'),
  ('b2c91120-3b2a-4875-801b-689ff2e43b9c', 'submitted', null, 'system', '2026-09-04 12:00:00'),
  ('b2c91120-3b2a-4875-801b-689ff2e43b9c', 'analyzed', null, 'system', '2026-09-08 17:00:00'),
  ('b2c91120-3b2a-4875-801b-689ff2e43b9c', 'screening', null, 'hr.au', '2026-09-10 22:00:00'),
  ('b2c91120-3b2a-4875-801b-689ff2e43b9c', 'interview', null, 'hr.au', '2026-09-13 02:00:00'),
  ('92c614a8-9960-421b-a854-28d17cb68a56', 'submitted', null, 'system', '2026-07-14 12:00:00'),
  ('92c614a8-9960-421b-a854-28d17cb68a56', 'analyzed', null, 'system', '2026-07-16 17:00:00'),
  ('92c614a8-9960-421b-a854-28d17cb68a56', 'screening', null, 'hr.au', '2026-07-19 00:00:00'),
  ('4cb32c78-14b0-427c-b444-0d07e5fa62bc', 'submitted', null, 'system', '2026-09-06 10:00:00'),
  ('4cb32c78-14b0-427c-b444-0d07e5fa62bc', 'analyzed', null, 'system', '2026-09-11 18:00:00'),
  ('5dfc8f0b-23ae-466d-b40f-efaddb0b39b8', 'submitted', null, 'system', '2026-10-08 09:00:00'),
  ('5dfc8f0b-23ae-466d-b40f-efaddb0b39b8', 'analyzed', null, 'system', '2026-10-12 17:00:00'),
  ('5dfc8f0b-23ae-466d-b40f-efaddb0b39b8', 'rejected', null, 'hr.au', '2026-10-19 00:00:00'),
  ('b7dc7788-b5e9-46df-9dba-c9fc1756c8bd', 'submitted', null, 'system', '2026-06-05 08:00:00');

commit;
