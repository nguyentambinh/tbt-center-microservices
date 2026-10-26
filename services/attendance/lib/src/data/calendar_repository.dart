/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:tbt_common/tbt_common.dart';

abstract interface class CalendarRepository {
  /// Từng ngày trong khoảng: ca làm, giờ vào ra, ngày lễ, đơn nghỉ
  Future<List<Map<String, dynamic>>> calendar(
    String employeeId, {
    required DateTime from,
    required DateTime to,
  });

  /// Tần suất chấm công: theo thứ trong tuần, theo giờ vào ca, đi trễ, theo
  /// tháng. [employeeId] null là cả khu vực (HR xem)
  Future<Map<String, dynamic>> stats({
    required DateTime from,
    required DateTime to,
    String? employeeId,
  });
}

class PostgresCalendarRepository implements CalendarRepository {
  PostgresCalendarRepository(this._db, {required this.countryCode});

  final Database _db;
  final String countryCode;

  @override
  Future<List<Map<String, dynamic>>> calendar(
    String employeeId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _db.query(
      'select d::date as day, s.shift_start::text as shift_start, '
      's.shift_end::text as shift_end, s.pay_coefficient::float8 as coef, '
      's.is_sunday, s.is_holiday, s.note, h.name as holiday, '
      't.check_in::text as check_in, t.check_out::text as check_out, '
      't.work_hours::float8 as work_hours, '
      't.overtime_hours::float8 as overtime_hours, '
      't.total_hours::float8 as total_hours, '
      'l.leave_type, l.status as leave_status '
      "from generate_series(@from::date, @to::date, interval '1 day') d "
      'left join work_schedules s on s.employee_id = @id and s.work_date = d '
      'left join timesheets t on t.employee_id = @id and t.work_date = d '
      'left join holidays h on h.country_code = @country '
      'and h.holiday_date = d '
      'left join lateral (select leave_type, status from leave_requests '
      "where employee_id = @id and status <> 'rejected' "
      'and d between from_date and to_date order by created_at desc limit 1) '
      'l on true order by d',
      params: {
        'id': employeeId,
        'from': from,
        'to': to,
        'country': countryCode,
      },
    );
    String? hhmm(Object? v) => v is String ? v.substring(0, 5) : null;
    return [
      for (final r in rows)
        {
          'date': (r['day'] as DateTime).toIso8601String().substring(0, 10),
          'shift': r['shift_start'] == null
              ? null
              : {
                  'start': hhmm(r['shift_start']),
                  'end': hhmm(r['shift_end']),
                  'coefficient': r['coef'],
                  'isSunday': r['is_sunday'],
                  'isHoliday': r['is_holiday'],
                  'note': r['note'],
                },
          'holiday': r['holiday'],
          'checkIn': hhmm(r['check_in']),
          'checkOut': hhmm(r['check_out']),
          'workHours': r['work_hours'],
          'overtimeHours': r['overtime_hours'],
          'totalHours': r['total_hours'],
          'leave': r['leave_type'] == null
              ? null
              : {'type': r['leave_type'], 'status': r['leave_status']},
        },
    ];
  }

  @override
  Future<Map<String, dynamic>> stats({
    required DateTime from,
    required DateTime to,
    String? employeeId,
  }) async {
    final params = {'id': employeeId, 'from': from, 'to': to};
    const scope =
        'from timesheets t left join work_schedules s '
        'on s.employee_id = t.employee_id and s.work_date = t.work_date '
        'where t.check_in is not null and t.work_date between @from and @to '
        'and (@id::text is null or t.employee_id = @id)';
    final weekday = await _db.query(
      'select extract(isodow from t.work_date)::int as dow, count(*)::int as n '
      '$scope group by 1 order by 1',
      params: params,
    );
    final hour = await _db.query(
      'select extract(hour from t.check_in)::int as h, count(*)::int as n '
      '$scope group by 1 order by 1',
      params: params,
    );
    final month = await _db.query(
      "select to_char(t.work_date, 'YYYY-MM') as m, count(*)::int as days, "
      'coalesce(sum(t.total_hours), 0)::float8 as hours, '
      'count(*) filter (where t.check_in > coalesce(s.shift_start, '
      "'08:00'))::int as late $scope group by 1 order by 1",
      params: params,
    );
    final byWeekday = List<int>.filled(7, 0);
    for (final r in weekday) {
      byWeekday[(r['dow'] as int) - 1] = r['n'] as int;
    }
    final byHour = List<int>.filled(24, 0);
    for (final r in hour) {
      byHour[r['h'] as int] = r['n'] as int;
    }
    final months = [
      for (final r in month)
        {
          'month': r['m'],
          'days': r['days'],
          'hours': r['hours'],
          'late': r['late'],
        },
    ];
    return {
      'byWeekday': byWeekday,
      'byCheckInHour': byHour,
      'byMonth': months,
      'totalDays': byWeekday.fold<int>(0, (a, b) => a + b),
      'lateDays': months.fold<int>(0, (a, m) => a + (m['late']! as int)),
    };
  }
}
