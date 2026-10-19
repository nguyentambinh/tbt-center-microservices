/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/work_time.dart';
import '../../domain/repositories/work_time_repository.dart';

class WorkTimeRepositoryImpl implements WorkTimeRepository {
  WorkTimeRepositoryImpl(this._dio, {required String baseUrl}) : _root = '$baseUrl/attendance';

  final Dio _dio;
  final String _root;

  @override
  Future<ClockToday> today() async {
    // Trạng thái hôm nay đổi sau mỗi lượt bấm, bản cache cũ dễ làm hiểu nhầm.
    final d = await _call(() => _dio.get<Map<String, dynamic>>(
          '$_root/clock',
          options: Options(extra: {noCache: true}),
        ));
    final shift = d['shift'] as Map<String, dynamic>?;
    return ClockToday(
      workDate: DateTime.parse(d['workDate'] as String),
      hasShift: d['hasShift'] == true,
      shiftNote: shift?['note'] as String?,
      coefficient: double.tryParse('${shift?['coefficient']}'),
      isHoliday: shift?['isHoliday'] == true,
      isSunday: shift?['isSunday'] == true,
      checkIn: d['checkIn'] as String?,
      checkOut: d['checkOut'] as String?,
      totalHours: (d['totalHours'] as num?)?.toDouble(),
      overtimeHours: (d['overtimeHours'] as num?)?.toDouble(),
    );
  }

  @override
  Future<ClockPunch> clock() async {
    final d = await _call(() => _dio.post<Map<String, dynamic>>('$_root/clock'));
    final checkedIn = d['action'] == 'checkIn';
    return ClockPunch(
      checkedIn: checkedIn,
      time: (checkedIn ? d['checkIn'] : d['checkOut']) as String,
      totalHours: (d['totalHours'] as num?)?.toDouble(),
      overtimeHours: (d['overtimeHours'] as num?)?.toDouble(),
    );
  }

  @override
  Future<List<OvertimeRequest>> overtimeRequests({bool pendingOnly = false}) async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>(
          '$_root/overtime-requests',
          queryParameters: {if (pendingOnly) 'status': 'pending'},
        ));
    return [for (final r in d['items'] as List) _overtime(r as Map<String, dynamic>)];
  }

  @override
  Future<OvertimeRequest> requestOvertime({required DateTime workDate, required double hours, String? reason}) async =>
      _overtime(await _call(() => _dio.post<Map<String, dynamic>>('$_root/overtime-requests', data: {
            'workDate': workDate.toIso8601String().substring(0, 10),
            'hours': hours,
            if (reason != null && reason.isNotEmpty) 'reason': reason,
          })));

  @override
  Future<OvertimeRequest> decideOvertime(String id, {required bool approve}) async => _overtime(await _call(
        () => _dio.post<Map<String, dynamic>>(
          '$_root/overtime-requests/${Uri.encodeComponent(id)}/decision',
          data: {'approve': approve},
        ),
      ));

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() request) async {
    try {
      return (await request()).data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static OvertimeRequest _overtime(Map<String, dynamic> j) => OvertimeRequest(
        id: j['id'] as String,
        employeeId: j['employeeId'] as String,
        workDate: DateTime.parse(j['workDate'] as String),
        hours: (j['hours'] as num).toDouble(),
        status: LeaveStatus.values.asNameMap()[j['status']] ?? LeaveStatus.pending,
        reason: j['reason'] as String?,
      );
}
