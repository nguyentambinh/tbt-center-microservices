-- Sinh tự động bởi tools/seed_data/generate.py, khu vực br. Không sửa tay.
begin;
truncate table candidate_status_history, candidate_documents, cv_summaries, candidate_import_rows, candidate_imports, candidates, outbox restart identity cascade;

insert into candidates (id, country_code, full_name, email, phone, applied_position, status, source, cv_object_key, consent_ai, created_at) values
  ('05f9f1a9-5739-47bf-b551-4e673745b3a9', 'BR', 'Gabriela Fernandes', 'gabriela.fernandes.0@example.com', '+55 31 99215-3301', 'Engenheiro Estrutural', 'interview', 'self', null, true, '2026-10-05 13:00:00'),
  ('125b170c-eecd-4275-a361-761dcfebbd38', 'BR', 'Aline Martins', 'aline.martins.1@example.com', '+55 11 92790-6667', 'Contador', 'submitted', 'self', null, true, '2026-09-06 10:00:00'),
  ('64e0ce5b-6426-4db0-877d-0b341c9b0603', 'BR', 'Gabriela Soares', 'gabriela.soares.2@example.com', '+55 41 92570-5955', 'Assistente Administrativo', 'screening', 'self', null, true, '2026-06-01 12:00:00'),
  ('576bf59b-0f60-48b3-a2fe-a9477724b8e7', 'BR', 'Diego Alves', 'diego.alves.3@example.com', '+55 41 96554-5246', 'Contador', 'submitted', 'self', null, true, '2026-06-04 12:00:00'),
  ('9221a909-77d3-464f-9cba-0522ca9d0838', 'BR', 'Juliana Pereira', 'juliana.pereira.4@example.com', '+55 41 95984-6159', 'Analista de RH', 'screening', 'self', null, true, '2026-07-11 11:00:00'),
  ('a45f6577-3fd1-43b1-b422-e06ffd0906f8', 'BR', 'Felipe Vieira', 'felipe.vieira.5@example.com', '+55 31 99462-6547', 'Analista de RH', 'offered', 'self', null, true, '2026-10-14 12:00:00'),
  ('c2190958-27a6-4b1d-814e-c8a74c0cea24', 'BR', 'João Ferreira', 'joao.ferreira.6@example.com', '+55 21 92364-6576', 'Engenheiro Estrutural', 'screening', 'self', null, true, '2026-07-02 12:00:00'),
  ('4c3e19b7-c2c1-487f-a56d-f7e6aa5e84b5', 'BR', 'Beatriz Carvalho', 'beatriz.carvalho.7@example.com', '+55 41 99606-9002', 'Assistente Administrativo', 'analyzed', 'self', null, true, '2026-06-04 17:00:00'),
  ('73a8e316-3d5c-4a64-b2dc-7261a3c98401', 'BR', 'Gabriela Pereira', 'gabriela.pereira.8@example.com', '+55 41 91297-1899', 'Técnico de Segurança do Trabalho', 'analyzed', 'self', null, true, '2026-08-07 08:00:00'),
  ('04fdcf89-fc51-4e78-87f4-85d0b7816101', 'BR', 'Fernanda Alves', 'fernanda.alves.9@example.com', '+55 11 92761-2404', 'Contador', 'submitted', 'self', null, true, '2026-10-05 16:00:00');

insert into candidate_status_history (candidate_id, status, note, changed_by, changed_at) values
  ('05f9f1a9-5739-47bf-b551-4e673745b3a9', 'submitted', null, 'system', '2026-10-05 13:00:00'),
  ('05f9f1a9-5739-47bf-b551-4e673745b3a9', 'analyzed', null, 'system', '2026-10-08 14:00:00'),
  ('05f9f1a9-5739-47bf-b551-4e673745b3a9', 'screening', null, 'hr.br', '2026-10-10 22:00:00'),
  ('05f9f1a9-5739-47bf-b551-4e673745b3a9', 'interview', null, 'hr.br', '2026-10-15 00:00:00'),
  ('125b170c-eecd-4275-a361-761dcfebbd38', 'submitted', null, 'system', '2026-09-06 10:00:00'),
  ('64e0ce5b-6426-4db0-877d-0b341c9b0603', 'submitted', null, 'system', '2026-06-01 12:00:00'),
  ('64e0ce5b-6426-4db0-877d-0b341c9b0603', 'analyzed', null, 'system', '2026-06-03 15:00:00'),
  ('64e0ce5b-6426-4db0-877d-0b341c9b0603', 'screening', null, 'hr.br', '2026-06-08 22:00:00'),
  ('576bf59b-0f60-48b3-a2fe-a9477724b8e7', 'submitted', null, 'system', '2026-06-04 12:00:00'),
  ('9221a909-77d3-464f-9cba-0522ca9d0838', 'submitted', null, 'system', '2026-07-11 11:00:00'),
  ('9221a909-77d3-464f-9cba-0522ca9d0838', 'analyzed', null, 'system', '2026-07-13 12:00:00'),
  ('9221a909-77d3-464f-9cba-0522ca9d0838', 'screening', null, 'hr.br', '2026-07-18 18:00:00'),
  ('a45f6577-3fd1-43b1-b422-e06ffd0906f8', 'submitted', null, 'system', '2026-10-14 12:00:00'),
  ('a45f6577-3fd1-43b1-b422-e06ffd0906f8', 'analyzed', null, 'system', '2026-10-18 19:00:00'),
  ('a45f6577-3fd1-43b1-b422-e06ffd0906f8', 'screening', null, 'hr.br', '2026-10-25 02:00:00'),
  ('a45f6577-3fd1-43b1-b422-e06ffd0906f8', 'interview', null, 'hr.br', '2026-10-26 10:00:00'),
  ('a45f6577-3fd1-43b1-b422-e06ffd0906f8', 'offered', null, 'hr.br', '2026-10-31 14:00:00'),
  ('c2190958-27a6-4b1d-814e-c8a74c0cea24', 'submitted', null, 'system', '2026-07-02 12:00:00'),
  ('c2190958-27a6-4b1d-814e-c8a74c0cea24', 'analyzed', null, 'system', '2026-07-07 18:00:00'),
  ('c2190958-27a6-4b1d-814e-c8a74c0cea24', 'screening', null, 'hr.br', '2026-07-09 21:00:00'),
  ('4c3e19b7-c2c1-487f-a56d-f7e6aa5e84b5', 'submitted', null, 'system', '2026-06-04 17:00:00'),
  ('4c3e19b7-c2c1-487f-a56d-f7e6aa5e84b5', 'analyzed', null, 'system', '2026-06-10 00:00:00'),
  ('73a8e316-3d5c-4a64-b2dc-7261a3c98401', 'submitted', null, 'system', '2026-08-07 08:00:00'),
  ('73a8e316-3d5c-4a64-b2dc-7261a3c98401', 'analyzed', null, 'system', '2026-08-11 14:00:00'),
  ('04fdcf89-fc51-4e78-87f4-85d0b7816101', 'submitted', null, 'system', '2026-10-05 16:00:00');

commit;
