/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/attendance.dart';
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
    );
