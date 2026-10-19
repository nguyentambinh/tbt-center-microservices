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
        _ => _messageForKind(l10n),
      };

  String _messageForKind(AppLocalizations l10n) => switch (kind) {
        FailureKind.network => l10n.errorNetwork,
        FailureKind.timeout => l10n.errorTimeout,
        FailureKind.server => l10n.errorServer,
        FailureKind.unauthorized => l10n.errorUnauthorized,
        FailureKind.forbidden => l10n.errorForbidden,
        FailureKind.notFound => l10n.errorNotFound,
        FailureKind.validation => serverMessage ?? l10n.errorValidation,
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
