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

/// GET /positions/{id}  vị trí kèm ứng viên, điểm phù hợp cao trước (HR).
/// PUT /positions/{id}  sửa thông tin, số người cần tuyển, đóng hoặc mở lại
Future<Response> onRequest(RequestContext context, String id) async {
  final claims = context.read<Claims>();
  final repository = context.read<PositionRepository>();
  final number = int.tryParse(id);
  if (number == null) return apiError(404, 'not_found', 'No position $id');
  switch (context.request.method) {
    case HttpMethod.get:
      if (!claims.hasAnyRole(recruiterRoles)) {
        return apiError(403, 'forbidden', 'HR only');
      }
      final found = await repository.find(number);
      return found == null
          ? apiError(404, 'not_found', 'No position $id')
          : Response.json(body: found);
    case HttpMethod.put:
      if (!claims.hasAnyRole(positionManagerRoles)) {
        return apiError(403, 'forbidden', 'HR only');
      }
      final input = await positionInputFrom(context);
      if (input == null) {
        return apiError(400, 'invalid_position', 'title, headcount needed');
      }
      try {
        final updated = await repository.update(number, input);
        return updated == null
            ? apiError(404, 'not_found', 'No position $id')
            : Response.json(body: updated);
      } on CandidateRuleViolation catch (e) {
        return positionViolation(e);
      }
    case HttpMethod.post ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, PUT only');
  }
}
