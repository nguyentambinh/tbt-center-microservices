/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:tbt_common/tbt_common.dart';

final _database = Database.fromEnvironment();
final _repository = PostgresProjectRepository(_database);
final _finance = InternalClient(
  'finance',
  Uri.parse(Platform.environment['FINANCE_URL'] ?? 'http://finance:8080'),
);

Handler middleware(Handler handler) {
  final protected = handler
      .use(idempotency(_database))
      .use(
        requireClaims(
          anyRole: const {'employee', 'hr', 'finance', 'admin', 'executive'},
          region: Platform.environment['REGION'],
        ),
      );

  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        return protected(context);
      })
      .use(provider<ProjectRepository>((_) => _repository))
      .use(provider<InternalClient>((_) => _finance))
      .use(correlationAndErrors())
      .use(metrics('project_contract'))
      .use(serviceRegistry('project_contract'));
}
