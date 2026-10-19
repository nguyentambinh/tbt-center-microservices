/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:attendance_service/src/domain/clock.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

abstract interface class ClockRepository {
  /// Lịch làm việc và trạng thái chấm công hôm nay theo giờ của khu vực.
  Future<Map<String, dynamic>> today(String employeeId);

  /// Chấm công một lượt; tự biết là vào ca hay ra ca (R31–R33).
  /// Ném [ClockRuleViolation] `no_shift` nếu hôm nay không có ca,
  /// `already_clocked_out` nếu đã ra ca, `too_soon` nếu vừa vào ca chưa đủ
  /// [minShift].
  Future<Map<String, dynamic>> clock(String employeeId);
}

class PostgresClockRepository implements ClockRepository {
  PostgresClockRepository(this._db, {required this.timeZone});

  final Database _db;

  /// Tên múi giờ IANA của khu vực, ví dụ `Asia/Ho_Chi_Minh`. Postgres đổi giờ
  /// (kể cả giờ mùa hè ở DE), service không phải tự tính.
  final String timeZone;

  @override
  Future<Map<String, dynamic>> today(String employeeId) async {
    final rows = await _db.query(
      'with t as (select (now() at time zone @tz) as local) '
      'select t.local::date as work_date, t.local::time::text as now, '
      's.note, s.pay_coefficient::text as coefficient, s.is_sunday, '
      's.is_holiday, ts.check_in::text as check_in, '
      'ts.check_out::text as check_out, ts.work_hours::float8 as work_hours, '
      'ts.overtime_hours::float8 as overtime_hours, '
      'ts.total_hours::float8 as total_hours, '
      '(s.employee_id is not null) as has_shift '
      'from t left join work_schedules s on s.employee_id = @id '
      'and s.work_date = t.local::date '
      'left join timesheets ts on ts.employee_id = @id '
      'and ts.work_date = t.local::date',
      params: {'id': employeeId, 'tz': timeZone},
      fromPrimary: true,
    );
    final r = rows.first;
    return {
      'workDate': (r['work_date'] as DateTime).toIso8601String().substring(
        0,
        10,
      ),
      'now': (r['now'] as String).substring(0, 5),
      'hasShift': r['has_shift'],
      'shift': r['has_shift'] == true
          ? {
              'note': r['note'],
              'coefficient': r['coefficient'],
              'isSunday': r['is_sunday'],
              'isHoliday': r['is_holiday'],
            }
          : null,
      'checkIn': _hhmm(r['check_in']),
      'checkOut': _hhmm(r['check_out']),
      'workHours': r['work_hours'],
      'overtimeHours': r['overtime_hours'],
      'totalHours': r['total_hours'],
    };
  }

  @override
  Future<Map<String, dynamic>> clock(String employeeId) {
    return _db.transaction((tx) async {
      final now = (await tx.execute(
        Sql.named(
          'select (now() at time zone @tz)::date as day, '
          '(now() at time zone @tz)::time(0)::text as time',
        ),
        parameters: {'tz': timeZone},
      )).first.toColumnMap();
      final day = now['day'] as DateTime;
      final time = now['time'] as String;
      final key = {'id': employeeId, 'day': day};

      // Khóa ca hôm nay: hai lượt bấm cùng lúc không cùng thành "vào ca".
      final shift = await tx.execute(
        Sql.named(
          'select 1 from work_schedules where employee_id = @id '
          'and work_date = @day for update',
        ),
        parameters: key,
      );
      if (shift.isEmpty) {
        throw const ClockRuleViolation(
          'no_shift',
          'No shift scheduled for today',
        );
      }

      final existing = await tx.execute(
        Sql.named(
          'select check_in::text as check_in, check_out from timesheets '
          'where employee_id = @id and work_date = @day',
        ),
        parameters: key,
      );
      final row = existing.isEmpty ? null : existing.first.toColumnMap();
      final checkIn = row?['check_in'] as String?;
      final checkedOut = row?['check_out'] != null;

      final Map<String, dynamic> result;
      if (checkIn == null) {
        await tx.execute(
          Sql.named(
            'insert into timesheets (employee_id, work_date, check_in) '
            'values (@id, @day, @time::time) on conflict (employee_id, '
            'work_date) do update set check_in = excluded.check_in',
          ),
          parameters: {...key, 'time': time},
        );
        result = {
          'action': ClockAction.checkIn.name,
          'workDate': _day(day),
          'checkIn': _hhmm(time),
        };
      } else if (checkedOut) {
        throw const ClockRuleViolation(
          'already_clocked_out',
          'Already clocked out today',
        );
      } else {
        final span = _parse(time).difference(_parse(checkIn));
        if (span < minShift) {
          throw const ClockRuleViolation(
            'too_soon',
            'Clock out at least 5 minutes after clocking in',
          );
        }
        final hours = splitHours(span);
        await tx.execute(
          Sql.named(
            'update timesheets set check_out = @time::time, '
            'work_hours = @work, overtime_hours = @overtime, '
            'total_hours = @total where employee_id = @id and work_date = @day',
          ),
          parameters: {
            ...key,
            'time': time,
            'work': hours.work,
            'overtime': hours.overtime,
            'total': hours.total,
          },
        );
        result = {
          'action': ClockAction.checkOut.name,
          'workDate': _day(day),
          'checkIn': _hhmm(checkIn),
          'checkOut': _hhmm(time),
          'workHours': hours.work,
          'overtimeHours': hours.overtime,
          'totalHours': hours.total,
        };
      }

      await addOutboxEvent(
        tx,
        aggregate: 'timesheet',
        aggregateId: '$employeeId:${_day(day)}',
        eventType: result['action'] == ClockAction.checkIn.name
            ? 'ClockedIn'
            : 'ClockedOut',
        payload: {'employeeId': employeeId, ...result},
      );
      return result;
    });
  }

  static DateTime _parse(String hhmmss) => DateTime.parse('2000-01-01 $hhmmss');

  static String? _hhmm(Object? value) =>
      value is String ? value.substring(0, 5) : null;

  static String _day(DateTime d) => d.toIso8601String().substring(0, 10);
}
