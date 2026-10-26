/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/position_routes.dart';
import 'package:recruitment_service/src/positions.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /positions  vị trí đang tuyển (còn chỗ); HR, quản lý thêm `?all=1`
/// để thấy cả vị trí đã đóng, đã đủ người.
/// POST /positions  HR mở vị trí mới {title, headcount, department,
/// description, requirements}
Future<Response> onRequest(RequestContext context) async {
  final claims = context.read<Claims>();
  final repository = context.read<PositionRepository>();
  switch (context.request.method) {
    case HttpMethod.get:
      final all =
          context.request.uri.queryParameters['all'] == '1' &&
          claims.hasAnyRole(recruiterRoles);
      return Response.json(
        body: {'items': await repository.list(openOnly: !all)},
      );
    case HttpMethod.post:
      if (!claims.hasAnyRole(positionManagerRoles)) {
        return apiError(403, 'forbidden', 'HR only');
      }
      final input = await positionInputFrom(context);
      if (input == null) {
        return apiError(400, 'invalid_position', 'title, headcount needed');
      }
      try {
        return Response.json(
          statusCode: 201,
          body: await repository.create(input, by: claims.username),
        );
      } on CandidateRuleViolation catch (e) {
        return positionViolation(e);
      }
    case HttpMethod.put ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
}
