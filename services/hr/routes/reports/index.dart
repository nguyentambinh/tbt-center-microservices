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

/// GET /reports: báo cáo nhân sự đã gửi. POST {period, note}: chụp số liệu
/// nhân sự hiện tại gửi Ban lãnh đạo; bản trước chưa xác nhận thì 409
Future<Response> onRequest(RequestContext context) async {
  final reports = context.read<ReportSubmissions>();
  final claims = context.read<Claims>();
  if (context.request.method == HttpMethod.get) {
    return Response.json(body: {'items': await reports.list()});
  }
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'GET or POST');
  }
  if (!claims.hasAnyRole(const {'hr'})) {
    return apiError(403, 'forbidden', 'HR or admin only');
  }
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } on Object {
    return apiError(400, 'invalid_json', 'Body must be a JSON object');
  }
  final period = (body['period'] as String?)?.trim() ?? '';
  if (period.isEmpty) return apiError(400, 'invalid_period', 'period needed');
  try {
    return Response.json(
      statusCode: 201,
      body: await reports.submit(
        period: period,
        data: await hrSnapshot(context.read<OrganizationRepository>()),
        by: claims.username,
        note: (body['note'] as String?)?.trim(),
      ),
    );
  } on ReportRuleViolation catch (e) {
    return apiError(409, e.code, e.message);
  }
}

/// Số liệu nhân sự lúc gửi: số người, theo phòng ban, chưa xếp phòng, đề cử
Future<Map<String, dynamic>> hrSnapshot(OrganizationRepository org) async {
  final departments = await org.departments();
  final employees = await org.activeEmployees();
  final unassigned = await org.unassigned();
  final nominations = await org.nominations();
  int count(String status) =>
      nominations.where((n) => n['status'] == status).length;
  return {
    'headcount': employees.length,
    'departments': departments.length,
    'unassigned': unassigned.length,
    'byDepartment': [
      for (final d in departments) {'name': d['name'], 'members': d['members']},
    ],
    'nominations': {
      'pending': count('pending'),
      'approved': count('approved'),
      'rejected': count('rejected'),
    },
  };
}
