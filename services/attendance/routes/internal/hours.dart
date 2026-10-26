/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/data/attendance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

/// GET /internal/hours?period=2026-10  tổng giờ công, tăng ca của từng nhân
/// viên trong kỳ (bước "lấy giờ công" của Saga chốt lương);
/// hoặc ?from=YYYY-MM-DD&to=YYYY-MM-DD cho khoảng ngày bất kỳ.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return apiError(405, 'method_not_allowed', 'GET only');
  }
  final query = context.request.uri.queryParameters;
  // Khoảng ngày tùy ý (xếp hạng, thứ tự trong phòng ban theo tổng giờ làm)
  final from = DateTime.tryParse(query['from'] ?? '');
  final to = DateTime.tryParse(query['to'] ?? '');
  if (from != null && to != null) {
    final items = await context.read<AttendanceRepository>().hoursByEmployee(
      from: from,
      to: to,
    );
    return Response.json(body: {'items': items});
  }
  final period = query['period'] ?? '';
  final month = DateTime.tryParse('$period-01');
  if (month == null || period.length != 7) {
    return apiError(400, 'invalid_period', 'period must be YYYY-MM');
  }

  final items = await context.read<AttendanceRepository>().hoursByEmployee(
    from: month,
    to: DateTime(month.year, month.month + 1, 0),
  );
  return Response.json(body: {'period': period, 'items': items});
}
