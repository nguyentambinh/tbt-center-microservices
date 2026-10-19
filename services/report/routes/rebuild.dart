/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dart_frog/dart_frog.dart';
import 'package:report_service/src/projector.dart';
import 'package:tbt_common/tbt_common.dart';

/// POST /rebuild  phát lại mọi sự kiện trong sổ audit để dựng lại mô hình
/// đọc (CQRS). Chỉ quản trị; báo cáo đầy đủ trở lại sau vài chục giây.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return apiError(405, 'method_not_allowed', 'POST only');
  }
  if (!context.read<Claims>().hasAnyRole(const {'admin'})) {
    return apiError(403, 'forbidden', 'Admins only');
  }
  await context.read<Projector>().rebuild();
  return Response.json(statusCode: 202, body: {'rebuilding': true});
}
