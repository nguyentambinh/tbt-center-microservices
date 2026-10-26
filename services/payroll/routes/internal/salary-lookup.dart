/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/payroll_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /internal/salary-lookup  {employeeIds: [...]}: lương cơ bản từng người
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final ids = [
    for (final id in body['employeeIds'] as List? ?? const [])
      if (id is String) id,
  ];
  if (ids.length > 2000) {
    return apiError(400, 'too_many', 'At most 2000 employees');
  }
  final items = await context.read<PayrollRepository>().salariesOf(ids);
  return Response.json(body: {'items': items});
}
