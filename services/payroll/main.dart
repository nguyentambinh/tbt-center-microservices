/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:payroll_service/src/dependencies.dart';
import 'package:tbt_common/tbt_common.dart';

/// Quá lâu không có bước mới thì coi là đợt bị treo
final _stallAfter = Duration(
  minutes:
      int.tryParse(Platform.environment['PAYROLL_STALL_MINUTES'] ?? '') ?? 10,
);

/// Tự chạy lại tối đa chừng này lần, quá thì chờ xử lý tay
const _maxAttempts = 3;

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // Khởi động lại giữa chừng thì chạy tiếp mọi đợt còn dở
  unawaited(_resume(Duration.zero));
  Timer.periodic(const Duration(minutes: 1), (_) => _resume(_stallAfter));
  return serve(handler, ip, port);
}

Future<void> _resume(Duration idle) async {
  try {
    final ids = idle == Duration.zero
        ? await runRepository.runningRunIds()
        : await runRepository.stalledRunIds(idle);
    for (final id in ids) {
      if (payrollSaga.active.contains(id)) continue;
      final run = await runRepository.run(id);
      if (run == null) continue;
      final attempts = await runRepository.countAttempt(id);
      if (attempts > _maxAttempts) {
        await runRepository.markNeedsAttention(
          id,
          'Đợt bị treo, đã tự chạy lại $_maxAttempts lần',
        );
        continue;
      }
      stdout.writeln(
        'Chạy tiếp đợt chốt lương ${run['period']} (lần $attempts)',
      );
      await runRepository.logStep(id, 'resume', 'started', 'lần $attempts');
      // Chạy tiếp không qua request: gắn id theo lượt chốt để tra log liền mạch
      unawaited(
        withCorrelationId(
          'saga-$id',
          () => payrollSaga.execute(id, run['period'] as String),
        ),
      );
    }
  } on Exception catch (e) {
    stderr.writeln('Không chạy tiếp được các đợt chốt lương: $e');
  }
}
