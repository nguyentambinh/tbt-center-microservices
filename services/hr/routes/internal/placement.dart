/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /internal/placement: phòng ban và chức vụ từng người, để recruitment
/// gợi ý phòng ban, mức lương lúc nhận việc
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final organization = context.read<OrganizationRepository>();
  final employees = await organization.activeEmployees();
  return Response.json(
    body: {
      'departments': await organization.departments(),
      'employees': [
        for (final e in employees)
          {
            'id': e['id'],
            'name': e['name'],
            'position': e['position'],
            'departmentId': e['departmentId'],
          },
      ],
    },
  );
}
