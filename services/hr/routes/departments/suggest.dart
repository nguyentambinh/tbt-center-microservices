/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/organization.dart';
import 'package:hr_service/src/responses.dart';

/// POST /departments/suggest  {employeeIds?, language}
/// AI gợi ý phòng ban cho người chưa có phòng, hoặc đề xuất lập phòng mới
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return methodNotAllowed('POST only');
  }
  final body = await jsonBody(context);
  final repository = context.read<OrganizationRepository>();
  final wanted = (body['employeeIds'] as List?)?.cast<String>().toSet();
  final people = [
    for (final p in await repository.unassigned())
      if (wanted == null || wanted.contains(p['id'])) p,
  ];
  final everyone = await repository.activeEmployees();
  final departments = [
    for (final d in await repository.departments())
      {
        'id': d['id'],
        'name': d['name'],
        'positions': [
          for (final e in everyone)
            if (e['departmentId'] == d['id'] && e['position'] != null)
              e['position'],
        ],
      },
  ];
  final result = await context.read<DepartmentAdvisor>().suggest(
    departments,
    people,
    language: body['language'] as String? ?? 'vi',
  );
  return Response.json(body: result);
}
