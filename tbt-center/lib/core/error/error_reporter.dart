/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_failure.dart';

/// Gắn vào MaterialApp để báo lỗi từ bất kỳ đâu, kể cả nơi không có BuildContext.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Báo lỗi ảnh hưởng tới người dùng bằng thông báo ở cuối màn hình.
/// Lỗi mạng không báo ở đây vì thanh kết nối trên cùng đã báo.
void reportFailure(Object error) {
  final messenger = scaffoldMessengerKey.currentState;
  final context = scaffoldMessengerKey.currentContext;
  if (messenger == null || context == null) return;

  final failure = error is AppFailure ? error : const AppFailure(FailureKind.unknown);
  if (failure.isConnectionProblem) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(failure.message(AppLocalizations.of(context))),
      behavior: SnackBarBehavior.floating,
    ));
}
