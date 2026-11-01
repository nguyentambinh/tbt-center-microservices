/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-11-01
 */

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/work_region.dart';
import '../../../core/config/env.dart';
import '../../../core/error/app_failure.dart';
import '../../../core/network/api_client.dart';

typedef ScheduledDay = ({DateTime date, String? start, String? end, String? note, bool clockedIn});

/// HR đặt lịch làm việc cho nhân viên ở khu vực đang xem
class ScheduleManageRepository {
  ScheduleManageRepository(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  Future<List<ScheduledDay>> days(String employeeId, DateTime from, DateTime to) async {
    final d = await _send(() => _dio.get<Map<String, dynamic>>('$baseUrl/attendance/calendar', queryParameters: {'employee': employeeId, 'from': _day(from), 'to': _day(to)}, options: Options(extra: {noCache: true})));
    return [
      for (final item in d['items'] as List? ?? const [])
        if (item case final Map<String, dynamic> day)
          (
            date: DateTime.parse(day['date'] as String),
            start: (day['shift'] as Map?)?['start'] as String?,
            end: (day['shift'] as Map?)?['end'] as String?,
            note: (day['shift'] as Map?)?['note'] as String?,
            clockedIn: day['checkIn'] != null,
          ),
    ];
  }

  Future<int> save({required List<String> employeeIds, required DateTime from, required DateTime to, required Set<int> weekdays, required String start, required String end, String? note}) async => _count(
        await _send(() => _dio.put<Map<String, dynamic>>('$baseUrl/attendance/schedules',
            data: {'employeeIds': employeeIds, 'from': _day(from), 'to': _day(to), 'weekdays': weekdays.toList(), 'start': start, 'end': end, 'note': ?note})),
      );

  Future<int> clear({required List<String> employeeIds, required DateTime from, required DateTime to}) async =>
      _count(await _send(() => _dio.delete<Map<String, dynamic>>('$baseUrl/attendance/schedules', data: {'employeeIds': employeeIds, 'from': _day(from), 'to': _day(to)})));

  static int _count(Map<String, dynamic> d) => (d['schedules'] as num? ?? 0).toInt();

  static String _day(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> _send(Future<Response<Map<String, dynamic>>> Function() call) async {
    try {
      return (await call()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }
}

final scheduleManageRepositoryProvider = Provider<ScheduleManageRepository>(
  (ref) => ScheduleManageRepository(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(ref.watch(workRegionProvider))),
);
