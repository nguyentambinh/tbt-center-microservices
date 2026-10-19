/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-18
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:knowledge_service/src/graph/reasoning_service.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /reasoner  kết quả suy luận gần nhất; POST chạy lại (HR, quản trị, ban điều hành)
Future<Response> onRequest(RequestContext context) async {
  final service = context.read<GraphReasoningService>();
  switch (context.request.method) {
    case HttpMethod.get:
      return Response.json(body: service.last ?? await service.run());
    case HttpMethod.post:
      if (!context.read<Claims>().hasAnyRole(const {
        'hr',
        'admin',
        'executive',
      })) {
        return apiError(403, 'forbidden', 'HR, admin or executive only');
      }
      return Response.json(body: await service.run());
    case HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options ||
        HttpMethod.patch ||
        HttpMethod.put:
      return apiError(405, 'method_not_allowed', 'GET or POST only');
  }
}
