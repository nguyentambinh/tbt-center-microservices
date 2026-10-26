/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hr_service/src/data/organization_repository.dart';
import 'package:hr_service/src/organization.dart';
import 'package:hr_service/src/responses.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /departments/{id}  trưởng phòng đầu tiên, còn lại theo tổng giờ làm
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return methodNotAllowed('GET only');
  }
  final dept = await context.read<OrganizationRepository>().department(id);
  if (dept == null) {
    return apiError(HttpStatus.notFound, 'not_found', 'No department $id');
  }
  var hours = <String, ({double work, double overtime, int days})>{};
  try {
    hours = await context.read<HoursLookup>()(
      from: DateTime(2000),
      to: DateTime.now(),
    );
  } on Object catch (e) {
    // Chấm công tạm lỗi: vẫn trả danh sách, giờ làm bằng 0
    stderr.writeln('Không đọc được giờ làm: $e');
  }
  final members = (dept['memberList'] as List).cast<Map<String, dynamic>>();
  return Response.json(
    body: {
      ...dept,
      'memberList': orderMembers(
        members,
        headId: dept['headId'] as String?,
        hours: hours,
      ),
    },
  );
}
