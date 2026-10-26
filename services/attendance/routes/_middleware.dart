/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:attendance_service/src/data/attendance_repository.dart';
import 'package:attendance_service/src/data/calendar_repository.dart';
import 'package:attendance_service/src/data/clock_repository.dart';
import 'package:attendance_service/src/data/overtime_repository.dart';
import 'package:attendance_service/src/data/period_lock.dart';
import 'package:attendance_service/src/data/work_config.dart';
import 'package:attendance_service/src/leave_files.dart';
import 'package:attendance_service/src/region_time.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:tbt_common/tbt_common.dart';

final _db = Database.fromEnvironment();
final _repository = PostgresAttendanceRepository(_db);
final _timeZone = Platform.environment['TIMEZONE'] ?? 'UTC';
final _clock = PostgresClockRepository(_db, timeZone: _timeZone);
final _regionClock = RegionClock(_db, timeZone: _timeZone);
final _overtime = PostgresOvertimeRepository(_db);
final _locks = PostgresPeriodLocks(_db);
final _calendar = PostgresCalendarRepository(
  _db,
  countryCode: Platform.environment['COUNTRY_CODE'] ?? 'VN',
);
final _leaveFiles = PostgresLeaveFileRepository(_db);
final _workConfig = PostgresWorkConfig(
  _db,
  countryCode: Platform.environment['COUNTRY_CODE'] ?? 'VN',
);
final _store = ObjectStore.fromEnvironment();
// Đọc giấy tờ, ảnh minh chứng cần đọc hiểu nên dùng Sonnet
final _summarizer = LeaveSummarizer(
  StructuredAi.fromEnvironment(null, claudeSonnet),
);

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
          anyRole: const {'employee', 'hr', 'finance', 'executive', 'admin'},
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
      .use(provider<RegionClock?>((_) => _regionClock))
      .use(provider<OvertimeRepository>((_) => _overtime))
      .use(provider<PeriodLocks>((_) => _locks))
      .use(provider<CalendarRepository>((_) => _calendar))
      .use(provider<LeaveFileRepository>((_) => _leaveFiles))
      .use(provider<WorkConfig>((_) => _workConfig))
      .use(provider<ObjectStore?>((_) => _store))
      .use(provider<LeaveSummarizer>((_) => _summarizer))
      .use(correlationAndErrors())
      .use(metrics('attendance'))
      .use(serviceRegistry('attendance'));
}
