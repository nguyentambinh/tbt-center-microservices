/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:attendance_service/src/data/period_lock.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

class WorkConfigViolation implements Exception {
  const WorkConfigViolation(this.code, this.message);

  final String code;
  final String message;
}

/// Cấu hình lịch làm việc do quản trị chỉnh: ngày lễ, giờ ca. Ghi sổ kiểm toán
abstract interface class WorkConfig {
  Future<void> addHoliday(DateTime date, String name, {required String by});

  /// `false` nếu không có ngày lễ đó
  Future<bool> removeHoliday(DateTime date, {required String by});

  /// Đổi giờ ca cho mọi lịch làm việc trong khoảng ngày (chỉ từ hôm nay trở
  /// đi để không sửa công đã chấm); trả số ca đã đổi
  Future<int> setShift({
    required DateTime from,
    required DateTime to,
    required String start,
    required String end,
    required String by,
  });

  /// HR đặt lịch cho từng người trong khoảng ngày, theo các thứ [weekdays]
  /// (1 là thứ Hai); ngày đã có lịch thì đổi giờ. Trả số ngày đã ghi
  Future<int> setSchedules({
    required List<String> employeeIds,
    required DateTime from,
    required DateTime to,
    required DateTime today,
    required List<int> weekdays,
    required String start,
    required String end,
    required String by,
    String? note,
  });

  /// Bỏ lịch trong khoảng ngày, giữ ngày đã chấm công. Trả số ngày đã bỏ
  Future<int> clearSchedules({
    required List<String> employeeIds,
    required DateTime from,
    required DateTime to,
    required DateTime today,
    required String by,
  });
}

class PostgresWorkConfig implements WorkConfig {
  PostgresWorkConfig(this._db, {required this.countryCode});

  final Database _db;
  final String countryCode;

  @override
  Future<void> addHoliday(DateTime date, String name, {required String by}) =>
      _db.transaction((tx) async {
        await tx.execute(
          Sql.named(
            'insert into holidays (country_code, holiday_date, name) '
            'values (@cc, @day, @name) on conflict (country_code, '
            'holiday_date) do update set name = excluded.name',
          ),
          parameters: {'cc': countryCode, 'day': date, 'name': name},
        );
        await tx.execute(
          Sql.named(
            'update work_schedules set is_holiday = true '
            'where work_date = @day',
          ),
          parameters: {'day': date},
        );
        await _event(tx, 'HolidayAdded', {
          'date': _day(date),
          'name': name,
          'by': by,
        });
      });

  @override
  Future<bool> removeHoliday(DateTime date, {required String by}) =>
      _db.transaction((tx) async {
        final deleted = await tx.execute(
          Sql.named(
            'delete from holidays where country_code = @cc '
            'and holiday_date = @day',
          ),
          parameters: {'cc': countryCode, 'day': date},
        );
        if (deleted.affectedRows == 0) return false;
        await tx.execute(
          Sql.named(
            'update work_schedules set is_holiday = false '
            'where work_date = @day',
          ),
          parameters: {'day': date},
        );
        await _event(tx, 'HolidayRemoved', {'date': _day(date), 'by': by});
        return true;
      });

  @override
  Future<int> setShift({
    required DateTime from,
    required DateTime to,
    required String start,
    required String end,
    required String by,
  }) {
    _checkShift(start, end);
    if (to.isBefore(from) || to.difference(from).inDays > 366) {
      throw const WorkConfigViolation(
        'invalid_range',
        'Pick at most one year',
      );
    }
    return _db.transaction((tx) async {
      final updated = await tx.execute(
        Sql.named(
          'update work_schedules set shift_start = @start::time, '
          'shift_end = @end::time where work_date between '
          'greatest(@from::date, current_date) and @to::date',
        ),
        parameters: {'start': start, 'end': end, 'from': from, 'to': to},
      );
      await _event(tx, 'ShiftChanged', {
        'from': _day(from),
        'to': _day(to),
        'start': start,
        'end': end,
        'schedules': updated.affectedRows,
        'by': by,
      });
      return updated.affectedRows;
    });
  }

  @override
  Future<int> setSchedules({
    required List<String> employeeIds,
    required DateTime from,
    required DateTime to,
    required DateTime today,
    required List<int> weekdays,
    required String start,
    required String end,
    required String by,
    String? note,
  }) {
    _checkShift(start, end);
    final first = _checkRange(employeeIds, from, to, today);
    if (weekdays.isEmpty || weekdays.any((d) => d < 1 || d > 7)) {
      throw const WorkConfigViolation('invalid_weekdays', 'Pick weekdays 1-7');
    }
    return _db.transaction((tx) async {
      await ensurePeriodsOpen(tx, first, to);
      final written = await tx.execute(
        Sql.named(
          'insert into work_schedules (employee_id, work_date, is_sunday, '
          'is_holiday, pay_coefficient, note, shift_start, shift_end) '
          'select e, d::date, extract(isodow from d) = 7, '
          'h.holiday_date is not null, case when h.holiday_date is not null '
          'then 3 when extract(isodow from d) = 7 then 2 else 1 end, @note, '
          '@start::time, @end::time from unnest(@ids) e cross join '
          "generate_series(@from::date, @to::date, interval '1 day') d "
          'left join holidays h on h.country_code = @cc '
          'and h.holiday_date = d::date '
          'where extract(isodow from d)::int = any(@days) '
          'on conflict (employee_id, work_date) do update set '
          'shift_start = excluded.shift_start, '
          'shift_end = excluded.shift_end, '
          'note = coalesce(excluded.note, work_schedules.note)',
        ),
        parameters: {
          'ids': TypedValue(Type.textArray, employeeIds),
          'days': TypedValue(Type.integerArray, weekdays),
          'from': first,
          'to': to,
          'cc': countryCode,
          'start': start,
          'end': end,
          'note': TypedValue(Type.text, note),
        },
      );
      await _event(tx, 'ScheduleChanged', {
        'employeeIds': employeeIds,
        'fromDate': _day(first),
        'toDate': _day(to),
        'start': start,
        'end': end,
        'schedules': written.affectedRows,
        'by': by,
      });
      return written.affectedRows;
    });
  }

  @override
  Future<int> clearSchedules({
    required List<String> employeeIds,
    required DateTime from,
    required DateTime to,
    required DateTime today,
    required String by,
  }) {
    final first = _checkRange(employeeIds, from, to, today);
    return _db.transaction((tx) async {
      await ensurePeriodsOpen(tx, first, to);
      final removed = await tx.execute(
        Sql.named(
          'delete from work_schedules s where s.employee_id = any(@ids) '
          'and s.work_date between @from and @to and not exists (select 1 '
          'from timesheets t where t.employee_id = s.employee_id '
          'and t.work_date = s.work_date and t.check_in is not null)',
        ),
        parameters: {
          'ids': TypedValue(Type.textArray, employeeIds),
          'from': first,
          'to': to,
        },
      );
      await _event(tx, 'ScheduleCleared', {
        'employeeIds': employeeIds,
        'fromDate': _day(first),
        'toDate': _day(to),
        'schedules': removed.affectedRows,
        'by': by,
      });
      return removed.affectedRows;
    });
  }

  static void _checkShift(String start, String end) {
    final pattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!pattern.hasMatch(start) || !pattern.hasMatch(end)) {
      throw const WorkConfigViolation('invalid_time', 'Use HH:mm');
    }
    if (start.compareTo(end) >= 0) {
      throw const WorkConfigViolation(
        'invalid_shift',
        'Shift must end after it starts',
      );
    }
  }

  /// Ngày đầu thực tế: không sửa lịch của ngày đã qua
  static DateTime _checkRange(
    List<String> employeeIds,
    DateTime from,
    DateTime to,
    DateTime today,
  ) {
    final day = DateTime(today.year, today.month, today.day);
    final first = from.isBefore(day) ? day : from;
    if (employeeIds.isEmpty || employeeIds.length > 200) {
      throw const WorkConfigViolation(
        'invalid_employees',
        'Pick 1 to 200 employees',
      );
    }
    if (to.isBefore(first) || to.difference(first).inDays > 92) {
      throw const WorkConfigViolation(
        'invalid_range',
        'Pick at most 3 months from today',
      );
    }
    return first;
  }

  Future<void> _event(
    TxSession tx,
    String type,
    Map<String, Object?> payload,
  ) => addOutboxEvent(
    tx,
    aggregate: 'work_config',
    aggregateId: countryCode,
    eventType: type,
    payload: payload,
  );

  static String _day(DateTime d) => d.toIso8601String().substring(0, 10);
}
