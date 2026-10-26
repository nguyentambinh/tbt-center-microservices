/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

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
