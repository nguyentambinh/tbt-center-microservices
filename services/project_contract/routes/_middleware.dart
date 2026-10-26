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
import 'package:project_contract_service/src/project_view.dart';
import 'package:project_contract_service/src/proposal_ai.dart';
import 'package:project_contract_service/src/proposals.dart';
import 'package:tbt_common/tbt_common.dart';

final _database = Database.fromEnvironment();
final _repository = PostgresProjectRepository(
  _database,
  media: MediaStore.fromEnvironment(),
);
final _env = Platform.environment;
final _finance = InternalClient(
  'finance',
  Uri.parse(_env['FINANCE_URL'] ?? 'http://finance:8080'),
);
final _rates = currencyRates(
  InternalClient(
    'currency',
    Uri.parse(_env['CURRENCY_URL'] ?? 'http://currency:8080'),
  ),
);
final _proposals = PostgresProposalRepository(
  _database,
  countryCode: _env['COUNTRY_CODE'] ?? 'VN',
  validate: (data) async => data.errors(
    rateToUsd: await _rates(data.currency ?? _env['CURRENCY'] ?? 'USD'),
    today: DateTime.now(),
  ),
);
final _advisor = ProposalAdvisor(
  ai: StructuredAi.fromEnvironment(),
  reader: StructuredAi.fromEnvironment(null, claudeSonnet, 'medium'),
  employees: hrEmployees(
    InternalClient('hr', Uri.parse(_env['HR_URL'] ?? 'http://hr:8080')),
  ),
);
final _files = ProjectFiles.fromEnvironment();
final _names = employeeNames(
  hrEmployees(
    InternalClient('hr', Uri.parse(_env['HR_URL'] ?? 'http://hr:8080')),
  ),
);

Handler middleware(Handler handler) {
  final internal = handler.use(requireInternalToken());
  final protected = handler
      .use(idempotency(_database))
      .use(
        requireClaims(
          anyRole: const {'employee', 'hr', 'finance', 'executive'},
          region: _env['REGION'],
          // Ban lãnh đạo ở Hub duyệt đề xuất dự án của mọi khu vực
        ),
      );

  return ((RequestContext context) {
        if (context.request.uri.path == '/') return handler(context);
        if (isInternalPath(context.request.uri)) return internal(context);
        return protected(context);
      })
      .use(provider<ProjectRepository>((_) => _repository))
      .use(provider<InternalClient>((_) => _finance))
      .use(provider<RateLookup>((_) => _rates))
      .use(provider<EmployeeNames>((_) => _names))
      .use(provider<ProposalRepository>((_) => _proposals))
      .use(provider<ProposalAdvisor>((_) => _advisor))
      .use(provider<ProjectFiles?>((_) => _files))
      .use(correlationAndErrors())
      .use(metrics('project_contract'))
      .use(serviceRegistry('project_contract'));
}
