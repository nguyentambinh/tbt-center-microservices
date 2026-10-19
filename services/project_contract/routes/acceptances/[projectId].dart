/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/access.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /acceptances/{mã dự án}  nghiệm thu dự án (R100): ghi doanh thu
/// nghiệm thu ở finance (gọi nội bộ), rồi đánh dấu dự án đã nghiệm thu.
Future<Response> onRequest(RequestContext context, String projectId) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  final claims = context.read<Claims>();
  if (!claims.hasAnyRole(customerContactRoles)) {
    return apiError(403, 'forbidden', 'Finance, admin or executive only');
  }

  final finance = context.read<InternalClient>();
  final today = DateTime.now();
  try {
    final project = await context.read<ProjectRepository>().accept(
      projectId,
      acceptedBy: claims.username,
      acceptedOn: DateTime(today.year, today.month, today.day),
      recordRevenue: (amount) => finance.post('/internal/acceptances', {
        'projectId': projectId,
        'acceptedOn': today.toIso8601String().substring(0, 10),
        'amount': amount,
      }, correlationId: context.request.headers['x-correlation-id']),
    );
    if (project == null) {
      return apiError(404, 'not_found', 'No project $projectId');
    }
    return Response.json(body: project);
  } on ProjectRuleViolation catch (e) {
    return apiError(409, e.code, e.message);
  } on InternalCallException catch (e) {
    // Tháng đã chốt sổ ở finance thì báo đúng lý do cho người dùng.
    final code = e.body['code'] as String?;
    if (code == 'period_closed') return apiError(409, code!, e.message);
    return apiError(503, 'finance_unavailable', e.message);
  }
}
