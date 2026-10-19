-- Sinh tự động bởi tools/seed_data/generate.py, khu vực de. Không sửa tay.
begin;
truncate table candidate_status_history, candidate_documents, cv_summaries, candidate_import_rows, candidate_imports, candidates, outbox restart identity cascade;

insert into candidates (id, country_code, full_name, email, phone, applied_position, status, source, cv_object_key, consent_ai, created_at) values
  ('2f4bde73-d58d-4a68-94b6-595df0e96f3e', 'DE', 'Felix Becker', 'felix.becker.0@example.com', '+49 155 2103569', 'Bauleiter', 'screening', 'self', null, true, '2026-06-11 09:00:00'),
  ('43b5f68d-8fd4-4522-9f9a-04011c9c81c1', 'DE', 'Jan Hoffmann', 'jan.hoffmann.1@example.com', '+49 157 6831049', 'Statiker', 'interview', 'self', null, true, '2026-06-07 08:00:00'),
  ('96c6c344-0ceb-40df-b33e-c1ffdd15a696', 'DE', 'Laura Krüger', 'laura.kruger.2@example.com', '+49 151 2408921', 'Bauleiter', 'interview', 'self', null, true, '2026-09-12 10:00:00'),
  ('2b8a7fff-010f-4ee7-a4ee-7530871fc50d', 'DE', 'Hannah Schmidt', 'hannah.schmidt.3@example.com', '+49 156 4436054', 'Projektleiter', 'screening', 'self', null, true, '2026-10-04 11:00:00'),
  ('819c81d5-f575-41d5-993b-a53aa11e7409', 'DE', 'Andreas Fischer', 'andreas.fischer.4@example.com', '+49 151 1984486', 'Projektleiter', 'submitted', 'self', null, true, '2026-09-02 11:00:00'),
  ('24d07c18-d26c-44ec-b528-f07d43351817', 'DE', 'Stefan Wagner', 'stefan.wagner.5@example.com', '+49 152 7299127', 'Statiker', 'submitted', 'self', null, true, '2026-07-09 10:00:00'),
  ('bffe1b2e-bbca-42ca-974c-f575957887de', 'DE', 'Jonas Zimmermann', 'jonas.zimmermann.6@example.com', '+49 156 2281595', 'Buchhalter', 'offered', 'self', null, true, '2026-10-05 08:00:00'),
  ('232a25f6-c177-4898-952f-8e19568e824b', 'DE', 'Katharina Weber', 'katharina.weber.7@example.com', '+49 156 8462563', 'Kaufmann für Büromanagement', 'offered', 'self', null, true, '2026-10-03 13:00:00'),
  ('9356c425-100f-4768-950b-799ad798ca2d', 'DE', 'Felix Richter', 'felix.richter.8@example.com', '+49 153 1505298', 'Buchhalter', 'rejected', 'self', null, true, '2026-10-02 11:00:00'),
  ('cdeca966-3e51-4921-9569-45fae6221ccb', 'DE', 'Paul Müller', 'paul.muller.9@example.com', '+49 153 3547608', 'Projektleiter', 'interview', 'self', null, true, '2026-08-07 15:00:00');

insert into candidate_status_history (candidate_id, status, note, changed_by, changed_at) values
  ('2f4bde73-d58d-4a68-94b6-595df0e96f3e', 'submitted', null, 'system', '2026-06-11 09:00:00'),
  ('2f4bde73-d58d-4a68-94b6-595df0e96f3e', 'analyzed', null, 'system', '2026-06-15 17:00:00'),
  ('2f4bde73-d58d-4a68-94b6-595df0e96f3e', 'screening', null, 'hr.de', '2026-06-20 23:00:00'),
  ('43b5f68d-8fd4-4522-9f9a-04011c9c81c1', 'submitted', null, 'system', '2026-06-07 08:00:00'),
  ('43b5f68d-8fd4-4522-9f9a-04011c9c81c1', 'analyzed', null, 'system', '2026-06-11 11:00:00'),
  ('43b5f68d-8fd4-4522-9f9a-04011c9c81c1', 'screening', null, 'hr.de', '2026-06-12 12:00:00'),
  ('43b5f68d-8fd4-4522-9f9a-04011c9c81c1', 'interview', null, 'hr.de', '2026-06-17 13:00:00'),
  ('96c6c344-0ceb-40df-b33e-c1ffdd15a696', 'submitted', null, 'system', '2026-09-12 10:00:00'),
  ('96c6c344-0ceb-40df-b33e-c1ffdd15a696', 'analyzed', null, 'system', '2026-09-16 13:00:00'),
  ('96c6c344-0ceb-40df-b33e-c1ffdd15a696', 'screening', null, 'hr.de', '2026-09-21 21:00:00'),
  ('96c6c344-0ceb-40df-b33e-c1ffdd15a696', 'interview', null, 'hr.de', '2026-09-26 03:00:00'),
  ('2b8a7fff-010f-4ee7-a4ee-7530871fc50d', 'submitted', null, 'system', '2026-10-04 11:00:00'),
  ('2b8a7fff-010f-4ee7-a4ee-7530871fc50d', 'analyzed', null, 'system', '2026-10-05 13:00:00'),
  ('2b8a7fff-010f-4ee7-a4ee-7530871fc50d', 'screening', null, 'hr.de', '2026-10-08 15:00:00'),
  ('819c81d5-f575-41d5-993b-a53aa11e7409', 'submitted', null, 'system', '2026-09-02 11:00:00'),
  ('24d07c18-d26c-44ec-b528-f07d43351817', 'submitted', null, 'system', '2026-07-09 10:00:00'),
  ('bffe1b2e-bbca-42ca-974c-f575957887de', 'submitted', null, 'system', '2026-10-05 08:00:00'),
  ('bffe1b2e-bbca-42ca-974c-f575957887de', 'analyzed', null, 'system', '2026-10-09 14:00:00'),
  ('bffe1b2e-bbca-42ca-974c-f575957887de', 'screening', null, 'hr.de', '2026-10-10 19:00:00'),
  ('bffe1b2e-bbca-42ca-974c-f575957887de', 'interview', null, 'hr.de', '2026-10-12 03:00:00'),
  ('bffe1b2e-bbca-42ca-974c-f575957887de', 'offered', null, 'hr.de', '2026-10-17 09:00:00'),
  ('232a25f6-c177-4898-952f-8e19568e824b', 'submitted', null, 'system', '2026-10-03 13:00:00'),
  ('232a25f6-c177-4898-952f-8e19568e824b', 'analyzed', null, 'system', '2026-10-09 15:00:00'),
  ('232a25f6-c177-4898-952f-8e19568e824b', 'screening', null, 'hr.de', '2026-10-14 17:00:00'),
  ('232a25f6-c177-4898-952f-8e19568e824b', 'interview', null, 'hr.de', '2026-10-17 00:00:00'),
  ('232a25f6-c177-4898-952f-8e19568e824b', 'offered', null, 'hr.de', '2026-10-23 08:00:00'),
  ('9356c425-100f-4768-950b-799ad798ca2d', 'submitted', null, 'system', '2026-10-02 11:00:00'),
  ('9356c425-100f-4768-950b-799ad798ca2d', 'analyzed', null, 'system', '2026-10-08 14:00:00'),
  ('9356c425-100f-4768-950b-799ad798ca2d', 'rejected', null, 'hr.de', '2026-10-10 19:00:00'),
  ('cdeca966-3e51-4921-9569-45fae6221ccb', 'submitted', null, 'system', '2026-08-07 15:00:00'),
  ('cdeca966-3e51-4921-9569-45fae6221ccb', 'analyzed', null, 'system', '2026-08-09 23:00:00'),
  ('cdeca966-3e51-4921-9569-45fae6221ccb', 'screening', null, 'hr.de', '2026-08-14 07:00:00'),
  ('cdeca966-3e51-4921-9569-45fae6221ccb', 'interview', null, 'hr.de', '2026-08-15 11:00:00');

commit;
