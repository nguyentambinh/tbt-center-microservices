/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:recruitment_service/src/dependencies.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'service': 'recruitment',
      'status': 'ok',
      // Trạng thái circuit breaker của lời gọi ra Claude API.
      'circuits': {'claude': claudeBreaker.state.name},
    },
  );
}
