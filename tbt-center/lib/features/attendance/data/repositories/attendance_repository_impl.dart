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
import '../../domain/entities/work_calendar.dart';
import '../../domain/repositories/attendance_repository.dart';

/// Gọi service `attendance` của khu vực người dùng qua Kong.
class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  @override
  Future<Timesheet> timesheet({required DateTime from, required DateTime to}) async {
    final data = await _call(() => _dio.get<Map<String, dynamic>>(
          '$baseUrl/attendance/timesheets',
          queryParameters: {'from': _date(from), 'to': _date(to)},
        ));
    return Timesheet(
      employeeId: data['employeeId'] as String,
      totalHours: (data['totalHours'] as num).toDouble(),
      days: [
        for (final r in data['items'] as List)
          TimesheetDay(
            date: DateTime.parse((r as Map<String, dynamic>)['workDate'] as String),
            checkIn: _time(r['checkIn']),
            checkOut: _time(r['checkOut']),
            workHours: (r['workHours'] as num?)?.toDouble() ?? 0,
            overtimeHours: (r['overtimeHours'] as num?)?.toDouble() ?? 0,
            totalHours: (r['totalHours'] as num?)?.toDouble() ?? 0,
          ),
      ],
    );
  }

  @override
  Future<List<LeaveRequest>> leaveRequests({bool pendingOnly = false}) async {
    final data = await _call(() => _dio.get<Map<String, dynamic>>(
          '$baseUrl/attendance/leave-requests',
          queryParameters: {if (pendingOnly) 'status': 'pending'},
        ));
    return [for (final r in data['items'] as List) leaveFromJson(r as Map<String, dynamic>)];
  }

  @override
  Future<LeaveRequest> requestLeave({
    required DateTime fromDate,
    required DateTime toDate,
    required String leaveType,
    String? reason,
  }) async {
    final data = await _call(() => _dio.post<Map<String, dynamic>>(
          '$baseUrl/attendance/leave-requests',
          data: {
            'fromDate': _date(fromDate),
            'toDate': _date(toDate),
            'leaveType': leaveType,
            if (reason != null && reason.isNotEmpty) 'reason': reason,
          },
        ));
    return leaveFromJson(data);
  }

  @override
  Future<LeaveRequest> decide(String id, {required bool approve}) async {
    final data = await _call(() => _dio.post<Map<String, dynamic>>(
          '$baseUrl/attendance/leave-requests/${Uri.encodeComponent(id)}/decision',
          data: {'approve': approve},
        ));
    return leaveFromJson(data);
  }

  @override
  Future<List<CalendarDay>> calendar({required DateTime from, required DateTime to}) async {
    final data = await _call(() => _dio.get<Map<String, dynamic>>(
          '$baseUrl/attendance/calendar',
          queryParameters: {'from': _date(from), 'to': _date(to)},
        ));
    return [for (final r in data['items'] as List) _calendarDay(r as Map<String, dynamic>)];
  }

  static CalendarDay _calendarDay(Map<String, dynamic> day) {
    final shift = day['shift'] as Map<String, dynamic>?;
    final leave = day['leave'] as Map<String, dynamic>?;
    return CalendarDay(
      date: DateTime.parse(day['date'] as String),
      shiftStart: shift?['start'] as String?,
      shiftEnd: shift?['end'] as String?,
      coefficient: (shift?['coefficient'] as num?)?.toDouble() ?? 1,
      isSunday: shift?['isSunday'] == true,
      isHoliday: shift?['isHoliday'] == true || day['holiday'] != null,
      note: shift?['note'] as String?,
      holiday: day['holiday'] as String?,
      checkIn: day['checkIn'] as String?,
      checkOut: day['checkOut'] as String?,
      workHours: (day['workHours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (day['overtimeHours'] as num?)?.toDouble() ?? 0,
      totalHours: (day['totalHours'] as num?)?.toDouble() ?? 0,
      leaveType: leave?['type'] as String?,
      leaveStatus: leave?['status'] as String?,
    );
  }

  @override
  Future<ClockStats> stats({int months = 3}) async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$baseUrl/attendance/timesheets/stats', queryParameters: {'months': months}));
    return ClockStats(
      byWeekday: [for (final n in d['byWeekday'] as List) n as int],
      byCheckInHour: [for (final n in d['byCheckInHour'] as List) n as int],
      byMonth: [
        for (final m in d['byMonth'] as List)
          (
            month: (m as Map<String, dynamic>)['month'] as String,
            days: m['days'] as int,
            hours: (m['hours'] as num).toDouble(),
            late: m['late'] as int,
          ),
      ],
      totalDays: d['totalDays'] as int? ?? 0,
      lateDays: d['lateDays'] as int? ?? 0,
    );
  }

  @override
  Future<List<LeaveFile>> leaveFiles(String leaveId) async => _files(await _call(() => _dio.get<Map<String, dynamic>>(
        '$baseUrl/attendance/leave-requests/${Uri.encodeComponent(leaveId)}/files',
        options: Options(extra: {noCache: true}),
      )));

  @override
  Future<List<LeaveFile>> uploadLeaveFile(String leaveId, {required String fileName, required List<int> bytes, required String language}) async {
    final root = '$baseUrl/attendance/leave-requests/${Uri.encodeComponent(leaveId)}/files';
    final target = await _call(() => _dio.post<Map<String, dynamic>>('$root/upload-url', data: {'fileName': fileName}));
    if (bytes.length > (target['maxBytes'] as int)) {
      throw const AppFailure(FailureKind.validation, serverCode: 'file_too_large');
    }
    // URL ký sẵn trỏ thẳng vào kho lưu trữ, không gắn token
    try {
      await _dio.put<void>(
        target['uploadUrl'] as String,
        data: Stream.fromIterable([bytes]),
        options: Options(headers: {Headers.contentLengthHeader: bytes.length}, extra: {noCache: true}),
      );
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
    return _files(await _call(() => _dio.post<Map<String, dynamic>>(
          root,
          queryParameters: {'language': language},
          data: {'objectKey': target['objectKey'], 'fileName': fileName},
        )));
  }

  static List<LeaveFile> _files(Map<String, dynamic> data) => [
        for (final f in data['items'] as List)
          LeaveFile(
            id: (f as Map<String, dynamic>)['id'] as String,
            fileName: f['fileName'] as String,
            mimeType: f['mimeType'] as String,
            url: f['url'] as String?,
          ),
      ];

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() request) async {
    try {
      return (await request()).data!;
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static String _date(DateTime d) => d.toIso8601String().substring(0, 10);

  /// Server trả `08:15:00`, chỉ hiện giờ:phút.
  static String? _time(Object? value) => value is String && value.length >= 5 ? value.substring(0, 5) : null;
}

LeaveRequest leaveFromJson(Map<String, dynamic> json) => LeaveRequest(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      fromDate: DateTime.parse(json['fromDate'] as String),
      toDate: DateTime.parse(json['toDate'] as String),
      days: json['days'] as int,
      leaveType: json['leaveType'] as String,
      status: LeaveStatus.values.asNameMap()[json['status']] ?? LeaveStatus.pending,
      reason: json['reason'] as String?,
      approvedBy: json['approvedBy'] as String?,
      aiSummary: json['aiSummary'] as Map<String, dynamic>?,
      aiSource: json['aiSource'] as String?,
      fileCount: json['fileCount'] as int? ?? 0,
    );
