/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../l10n/app_localizations.dart';

enum FailureKind { network, timeout, server, unauthorized, forbidden, notFound, validation, offlineWrite, unknown }

/// Lỗi đã quy về một số loại cố định để giao diện báo đúng câu cho người dùng.
class AppFailure implements Exception {
  const AppFailure(this.kind, {this.statusCode, this.serverMessage, this.serverCode});

  factory AppFailure.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    final message = body is Map ? body['message'] as String? : null;
    final code = body is Map ? body['code'] as String? : null;
    return switch (error.type) {
      DioExceptionType.connectionError => const AppFailure(FailureKind.network),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const AppFailure(FailureKind.timeout),
      DioExceptionType.badResponse =>
        AppFailure(_kindForStatus(status), statusCode: status, serverMessage: message, serverCode: code),
      _ when error.error is AppFailure => error.error! as AppFailure,
      _ => AppFailure(FailureKind.unknown, statusCode: status),
    };
  }

  final FailureKind kind;
  final int? statusCode;
  final String? serverMessage;

  /// Mã lỗi nghiệp vụ server trả về (`overlap`, `self_approval`…), có câu báo riêng.
  final String? serverCode;

  /// Lỗi mạng thì đã có thanh báo trên cùng lo, không cần hiện thêm thông báo riêng.
  bool get isConnectionProblem => kind == FailureKind.network || kind == FailureKind.timeout;

  String message(AppLocalizations l10n) => switch (serverCode) {
        'overlap' => l10n.errOverlap,
        'too_long' => l10n.errTooLong,
        'invalid_dates' => l10n.errInvalidDates,
        'already_decided' => l10n.errAlreadyDecided,
        'self_approval' => l10n.errSelfApproval,
        'period_locked' => l10n.errPeriodLocked,
        'region_mismatch' => l10n.errRegionMismatch,
        'no_employee' => l10n.errNoEmployee,
        'profile_locked' => l10n.errProfileLocked,
        'run_exists' => l10n.errRunExists,
        'run_failed' => l10n.errRunFailed,
        'not_calculated' => l10n.payoutNotCalculated,
        'run_running' || 'payout_busy' => l10n.payoutBusy,
        'payout_failed' => l10n.errPayoutFailed,
        'cv_not_pdf' => l10n.errCvNotPdf,
        'cv_too_large' => l10n.errCvTooLarge,
        'period_closed' => l10n.errPeriodClosed,
        'period_not_ended' => l10n.errPeriodNotEnded,
        'overpaid' => l10n.errOverpaid,
        'invalid_amount' => l10n.errInvalidAmount,
        'no_shift' => l10n.errNoShift,
        'already_clocked_out' => l10n.errAlreadyClockedOut,
        'too_soon' => l10n.errTooSoon,
        'invalid_hours' => l10n.errInvalidHours,
        'unsupported_file' => l10n.errUnsupportedFile,
        'missing_name_column' => l10n.errMissingNameColumn,
        'empty_file' => l10n.errEmptyFile,
        'file_too_large' => l10n.errFileTooLarge,
        'access_expired' => l10n.errAccessExpired,
        'already_accepted' => l10n.errAlreadyAccepted,
        'finance_unavailable' => l10n.errFinanceUnavailable,
        'is_head' => l10n.errIsHead,
        'last_member' => l10n.errLastMember,
        'same_department' => l10n.errSameDepartment,
        'archived' => l10n.errArchived,
        'not_archived' => l10n.errNotArchived,
        'members_remaining' => l10n.errMembersRemaining,
        'not_member' => l10n.errNotMember,
        'pending_exists' => l10n.errPendingExists,
        'attendance_unavailable' || 'projects_unavailable' || 'placement_unavailable' => l10n.errServiceUnavailable,
        'invalid_transition' || 'use_interview' || 'use_minutes' || 'use_hire' || 'invalid_interview_action' || 'no_interview' || 'interview_exists' => l10n.errInvalidStep,
        'not_screened' => l10n.errNotScreened,
        'time_in_past' || 'time_required' => l10n.errTimeInPast,
        'interview_not_confirmed' => l10n.errInterviewNotConfirmed,
        'interview_not_held' => l10n.minutesAfterInterview,
        'not_interviewed' => l10n.errNotInterviewed,
        'not_rejected' => l10n.errNotRejected,
        'invalid_offer' => l10n.errInvalidOffer,
        'invalid_file' || 'file_missing' => l10n.errFileType,
        'shift_ended' => l10n.errShiftEnded,
        'payroll_too_early' => l10n.errPayrollTooEarly,
        'amount_lowered' => l10n.errAmountLowered,
        'not_higher' => l10n.errNotHigher,
        'no_salary' => l10n.errNoSalary,
        'awaiting_ack' => l10n.errAwaitingAck,
        'invalid_raise_action' || 'invalid_report_action' => l10n.errInvalidStep,
        'too_many_files' => l10n.errTooManyFiles,
        'notice_too_short' => l10n.errNoticeTooShort,
        'no_position' => l10n.errNoPosition,
        'not_higher_position' => l10n.errNotHigherPosition,
        'unknown_position' => l10n.errUnknownPosition,
        'invalid_email' => l10n.errInvalidEmail,
        'invalid_name' => l10n.errInvalidName,
        'invalid_phone' => l10n.errInvalidPhone,
        'weak_password' => l10n.errWeakPassword,
        'email_taken' => l10n.errEmailTaken,
        'code_too_soon' => l10n.errCodeTooSoon,
        'code_expired' || 'code_not_found' => l10n.errCodeExpired,
        'wrong_code' => l10n.errWrongCode,
        'signup_unavailable' => l10n.errSignupUnavailable,
        'too_many_positions' => l10n.errTooManyPositions,
        'position_not_found' || 'position_unavailable' => l10n.errPositionUnavailable,
        'title_exists' => l10n.errPositionTitleExists,
        'invalid_headcount' || 'headcount_below_hired' => l10n.errInvalidHeadcount,
        'invalid_title' || 'invalid_position' => l10n.errInvalidPosition,
        'before_last_day' => l10n.errBeforeLastDay,
        'invalid_resignation_action' => l10n.errInvalidStep,
        'group_only' => l10n.errGroupOnly,
        'same_position' => l10n.errSamePosition,
        'in_use' => l10n.errInUse,
        'read_only' => l10n.errReadOnly,
        'sql_error' => l10n.errSqlError,
        'unknown_database' => l10n.errUnknownDatabase,
        'protected_database' => l10n.errProtectedDatabase,
        'empty_sql' => l10n.errEmptySql,
        'storage_unavailable' => l10n.errStorageUnavailable,
        'identity_unavailable' => l10n.errIdentityUnavailable,
        'other_region' => l10n.errOtherRegion,
        'role_not_allowed' => l10n.errRoleNotAllowed,
        'self_change' => l10n.errSelfChange,
        'invalid_shift' || 'invalid_time' => l10n.errInvalidShift,
        'invalid_range' => l10n.errInvalidRange,
        _ => _messageForKind(l10n),
      };

  String _messageForKind(AppLocalizations l10n) => switch (kind) {
        FailureKind.network => l10n.errorNetwork,
        FailureKind.timeout => l10n.errorTimeout,
        FailureKind.server => l10n.errorServer,
        FailureKind.unauthorized => l10n.errorUnauthorized,
        FailureKind.forbidden => l10n.errorForbidden,
        FailureKind.notFound => l10n.errorNotFound,
        FailureKind.validation => l10n.errorValidation,
        FailureKind.offlineWrite => l10n.errorOfflineWrite,
        FailureKind.unknown => l10n.errorUnknown,
      };

  static FailureKind _kindForStatus(int? status) => switch (status) {
        401 => FailureKind.unauthorized,
        403 => FailureKind.forbidden,
        404 => FailureKind.notFound,
        400 || 409 || 422 => FailureKind.validation,
        final s? when s >= 500 => FailureKind.server,
        _ => FailureKind.unknown,
      };

  @override
  String toString() => 'AppFailure($kind, status: $statusCode)';
}
