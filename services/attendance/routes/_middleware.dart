/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:attendance_service/src/data/attendance_repository.dart';
import 'package:attendance_service/src/data/clock_repository.dart';
import 'package:attendance_service/src/data/overtime_repository.dart';
import 'package:attendance_service/src/data/period_lock.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _db = Database.fromEnvironment();
final _repository = PostgresAttendanceRepository(_db);
final _clock = PostgresClockRepository(
  _db,
  timeZone: Platform.environment['TIMEZONE'] ?? 'UTC',
);
final _overtime = PostgresOvertimeRepository(_db);
final _locks = PostgresPeriodLocks(_db);

/// - GET / kiểm tra sống: không cần gì.
/// - /internal/...: chỉ service khác trong khu vực (Saga chốt lương) gọi,
///   cần `X-Internal-Token`.
/// - còn lại: cần token của người trong khu vực, ứng viên không dùng.
Handler middleware(Handler handler) {
  final internal = handler.use(requireInternalToken());
  final protected = handler
      .use(idempotency(_db))
      .use(
        requireClaims(
          anyRole: const {'employee', 'hr', 'finance', 'admin', 'executive'},
          region: Platform.environment['REGION'],
        ),
      );

  return ((RequestContext context) {
        final uri = context.request.uri;
        if (uri.path == '/') return handler(context);
        if (isInternalPath(uri)) return internal(context);
        return protected(context);
      })
      .use(provider<AttendanceRepository>((_) => _repository))
      .use(provider<ClockRepository>((_) => _clock))
      .use(provider<OvertimeRepository>((_) => _overtime))
      .use(provider<PeriodLocks>((_) => _locks))
      .use(correlationAndErrors())
      .use(metrics('attendance'))
      .use(serviceRegistry('attendance'));
}
