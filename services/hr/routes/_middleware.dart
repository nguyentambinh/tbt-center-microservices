/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/employee_repository.dart';
import 'package:tbt_common/tbt_common.dart';

// Mở pool kết nối một lần cho cả service, ở request đầu tiên cần tới.
final _repository = PostgresEmployeeRepository(Database.fromEnvironment());

Handler middleware(Handler handler) {
  return handler
      .use(provider<EmployeeRepository>((_) => _repository))
      .use(correlationAndErrors())
      .use(metrics('hr'))
      .use(serviceRegistry('hr'));
}
