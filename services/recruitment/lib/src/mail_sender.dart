/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:async';
import 'dart:io';

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:tbt_common/tbt_common.dart';

typedef SendMail = Future<void> Function(
  String to,
  String subject,
  String body,
);

/// Xếp email vào hàng đợi, MailSender gửi sau (lỗi mạng thì tự thử lại)
SendMail queueMail(Database db) => (to, subject, body) => db.execute(
  'insert into email_queue (recipient, subject, body) '
  'values (@to, @subject, @body)',
  params: {'to': to, 'subject': subject, 'body': body},
);

/// Gửi email trong `email_queue` qua SMTP; chưa cấu hình thì để nguyên hàng
/// đợi, app vẫn có thông báo
class MailSender {
  MailSender(
    this._db, {
    required this.send,
    this.interval = const Duration(seconds: 30),
    this.maxAttempts = 5,
  });

  final Database _db;
  final SendMail send;
  final Duration interval;
  final int maxAttempts;
  Timer? _timer;

  void start() {
    _timer ??= Timer.periodic(interval, (_) => unawaited(_drain()));
  }

  void stop() => _timer?.cancel();

  bool _running = false;

  Future<void> _drain() async {
    if (_running) return;
    _running = true;
    try {
      await sendPending();
    } on Object catch (e) {
      stderr.writeln('Gửi email lỗi: $e');
    } finally {
      _running = false;
    }
  }

  /// Gửi tối đa 20 email đang chờ, trả số email đã gửi
  Future<int> sendPending() async {
    final rows = await _db.query(
      'select id, recipient, subject, body from email_queue '
      "where status = 'pending' order by id limit 20",
      fromPrimary: true,
    );
    var sent = 0;
    for (final r in rows) {
      try {
        await send(
          r['recipient'] as String,
          r['subject'] as String,
          r['body'] as String,
        );
        await _db.execute(
          "update email_queue set status = 'sent', sent_at = now(), "
          'attempts = attempts + 1 where id = @id',
          params: {'id': r['id']},
        );
        sent++;
      } on Object catch (e) {
        await _db.execute(
          'update email_queue set attempts = attempts + 1, last_error = @e, '
          "status = case when attempts + 1 >= @max then 'failed' "
          "else 'pending' end where id = @id",
          params: {'id': r['id'], 'e': '$e', 'max': maxAttempts},
        );
      }
    }
    return sent;
  }
}

/// SMTP lấy từ biến môi trường (`deploy/secrets/smtp.env`); thiếu thì null
SendMail? smtpFromEnvironment([Map<String, String>? environment]) {
  final env = environment ?? Platform.environment;
  final user = env['SMTP_USER'] ?? '';
  // Mật khẩu ứng dụng Gmail hay chép kèm khoảng trắng giữa các nhóm 4 chữ
  final password = (env['SMTP_PASSWORD'] ?? '').replaceAll(' ', '');
  if (user.isEmpty || password.isEmpty) return null;
  final server = SmtpServer(
    env['SMTP_HOST'] ?? 'smtp.gmail.com',
    port: int.tryParse(env['SMTP_PORT'] ?? '') ?? 587,
    username: user,
    password: password,
  );
  final from = mailer.Address(user, env['SMTP_FROM_NAME'] ?? 'TBT Center');
  return (to, subject, body) async {
    final message = mailer.Message()
      ..from = from
      ..recipients.add(to)
      ..subject = subject
      ..text = body;
    await mailer.send(message, server);
  };
}
