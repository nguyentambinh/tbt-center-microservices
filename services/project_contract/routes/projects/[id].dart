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
import 'package:project_contract_service/src/project_view.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /projects/{id}  hợp đồng, khách hàng, nhân sự tham gia, ảnh dự án.
Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final claims = context.read<Claims>();
  final repository = context.read<ProjectRepository>();
  final viewer = claims.hasAnyRole(projectViewerRoles);
  final employee = claims.employeeId;
  // Nhân viên thường chỉ xem được dự án mình tham gia
  if (!viewer &&
      (employee == null || !await repository.isMember(id, employee))) {
    return apiError(403, 'forbidden', 'Not allowed to view this project');
  }

  final project = await repository.project(id);
  if (project == null) return apiError(404, 'not_found', 'No project $id');
  final names = await context.read<EmployeeNames>()();
  project['members'] = [
    for (final m in project['members'] as List)
      {
        ...(m as Map<String, dynamic>),
        'name': names[m['employeeId']],
        'isMe': m['employeeId'] == employee,
      },
  ];

  if (!viewer) {
    // Không lộ tiền hợp đồng, lương dự án của đồng nghiệp, liên hệ khách
    project
      ..remove('deposit')
      ..remove('expectedAcceptance')
      ..remove('customerNotices');
    // Chỉ thấy tên đồng nghiệp; tiền dự án chỉ của chính mình
    project['members'] = [
      for (final m in project['members'] as List)
        if ((m as Map<String, dynamic>)['isMe'] == true)
          m
        else
          {...m}
            ..remove('projectSalary')
            ..remove('employeeId'),
    ];
  }

  final customer = project['customer'] as Map<String, dynamic>?;
  if (customer != null && !claims.hasAnyRole(customerContactRoles)) {
    project['customer'] = {
      'id': customer['id'],
      'name': customer['name'],
      'type': customer['type'],
    };
  }
  if (!viewer) return Response.json(body: project);
  final currency = project['currency'] as String? ?? 'USD';
  return Response.json(
    body: decorateProject(
      project,
      rateToUsd: await context.read<RateLookup>()(currency),
      today: DateTime.now(),
    ),
  );
}
