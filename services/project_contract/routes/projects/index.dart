/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:project_contract_service/src/access.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:project_contract_service/src/project_rules.dart';
import 'package:project_contract_service/src/project_view.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /projects?q=&tier=&limit=&offset=  dự án theo hợp đồng, khách hàng
/// (R100), kèm phân cấp, tiến độ, mức cảnh báo
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  if (!context.read<Claims>().hasAnyRole(projectViewerRoles)) {
    return apiError(403, 'forbidden', 'Not allowed to view projects');
  }
  final query = context.request.uri.queryParameters;
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100);
  final offset = (int.tryParse(query['offset'] ?? '') ?? 0).clamp(0, 1 << 30);

  final currency = Platform.environment['CURRENCY'] ?? 'USD';
  final rate = await context.read<RateLookup>()(currency);
  final page = await context.read<ProjectRepository>().projects(
    search: query['q']?.trim(),
    tier: int.tryParse(query['tier'] ?? ''),
    from: DateTime.tryParse(query['from'] ?? ''),
    to: DateTime.tryParse(query['to'] ?? ''),
    rateToUsd: rate,
    limit: limit,
    offset: offset,
  );
  final today = DateTime.now();
  return Response.json(
    body: {
      'items': [
        for (final p in page.items)
          decorateProject(p, rateToUsd: rate, today: today),
      ],
      'total': page.total,
      'tierThresholdsUsd': tierThresholdsUsd,
    },
  );
}
