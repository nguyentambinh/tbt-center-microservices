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

/// GET /rankings?months=3&departmentId=&limit=20  nhân viên xuất sắc
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return methodNotAllowed('GET only');
  }
  final query = context.request.uri.queryParameters;
  final months = (int.tryParse(query['months'] ?? '') ?? 3).clamp(1, 36);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - months + 1);
  final Map<String, ({double work, double overtime, int days})> hours;
  try {
    hours = await context.read<HoursLookup>()(from: from, to: now);
  } on Object catch (e) {
    stderr.writeln('Không đọc được giờ làm: $e');
    return apiError(
      HttpStatus.badGateway,
      'attendance_unavailable',
      'Attendance is not reachable',
    );
  }
  final employees = await context
      .read<OrganizationRepository>()
      .activeEmployees(departmentId: query['departmentId']);
  return Response.json(
    body: {
      'from': from.toIso8601String().substring(0, 10),
      'to': now.toIso8601String().substring(0, 10),
      'items': rankEmployees(employees, hours, limit: limit),
    },
  );
}
