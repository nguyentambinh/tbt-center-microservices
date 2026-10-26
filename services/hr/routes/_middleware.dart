/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/change_request_repository.dart';
import 'package:hr_service/src/data/employee_repository.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/data/position_catalog.dart';
import 'package:hr_service/src/organization.dart';
import 'package:tbt_common/tbt_common.dart';

// Mở pool kết nối một lần cho cả service, ở request đầu tiên cần tới.
final _database = Database.fromEnvironment();
final _repository = PostgresEmployeeRepository(
  _database,
  media: MediaStore.fromEnvironment(),
);
final _changeRequests = PostgresChangeRequestRepository(_database);
final _organization = PostgresOrganizationRepository(
  _database,
  media: MediaStore.fromEnvironment(),
);
final _env = Platform.environment;
InternalClient _client(String name) => InternalClient(
  name,
  Uri.parse(_env['${name.toUpperCase()}_URL'] ?? 'http://$name:8080'),
);
final _attendance = _client('attendance');
final _projects = InternalClient(
  'project_contract',
  Uri.parse(_env['PROJECT_CONTRACT_URL'] ?? 'http://project-contract:8080'),
);
final _payroll = _client('payroll');
final _advisor = DepartmentAdvisor.fromEnvironment();
final _keycloak = KeycloakUsers.fromEnvironment();
final _positions = PostgresPositionCatalog(_database);

Handler middleware(Handler handler) {
  return handler
      .use(provider<EmployeeRepository>((_) => _repository))
      .use(provider<ChangeRequestRepository>((_) => _changeRequests))
      .use(provider<OrganizationRepository>((_) => _organization))
      .use(provider<HoursLookup>((_) => attendanceHours(_attendance)))
      .use(provider<ProjectsOf>((_) => projectsOf(_projects)))
      .use(provider<RemoveFromProjects>((_) => removeFromProjects(_projects)))
      .use(provider<RaiseSalary>((_) => raiseSalary(_payroll)))
      .use(provider<DepartmentAdvisor>((_) => _advisor))
      .use(provider<KeycloakUsers>((_) => _keycloak))
      .use(provider<PositionCatalog>((_) => _positions))
      .use(correlationAndErrors())
      .use(metrics('hr'))
      .use(serviceRegistry('hr'));
}
