/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/data/clock_repository.dart';
import 'package:attendance_service/src/domain/clock.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET  /clock  ca hôm nay và đã vào/ra ca chưa
/// POST /clock  chấm công: lần đầu là vào ca, lần hai là ra ca (R31–R33).
/// Giờ lấy theo đồng hồ server và múi giờ khu vực, không tin giờ trên máy.
Future<Response> onRequest(RequestContext context) async {
  final employee = context.read<Claims>().employeeId;
  if (employee == null) {
    return apiError(403, 'no_employee', 'Account is not linked to an employee');
  }
  final repository = context.read<ClockRepository>();

  switch (context.request.method) {
    case HttpMethod.get:
      return Response.json(body: await repository.today(employee));
    case HttpMethod.post:
      try {
        return Response.json(
          statusCode: 201,
          body: await repository.clock(employee),
        );
      } on ClockRuleViolation catch (e) {
        return apiError(409, e.code, e.message);
      }
    case HttpMethod.put ||
        HttpMethod.patch ||
        HttpMethod.delete ||
        HttpMethod.head ||
        HttpMethod.options:
      return apiError(405, 'method_not_allowed', 'GET, POST only');
  }
}
