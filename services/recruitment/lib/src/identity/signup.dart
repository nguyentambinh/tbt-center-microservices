/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:recruitment_service/src/identity/keycloak_admin.dart';
import 'package:recruitment_service/src/mail_sender.dart';
import 'package:tbt_common/tbt_common.dart';

/// Mã xác nhận hết hạn sau 10 phút, sai quá 5 lần thì phải xin mã mới
const signupCodeTtl = Duration(minutes: 10);
const signupMaxAttempts = 5;
const signupResendGap = Duration(seconds: 60);

class SignupViolation implements Exception {
  const SignupViolation(this.statusCode, this.code, this.message);

  final int statusCode;
  final String code;
  final String message;
}

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _phone = RegExp(r'^\+?[0-9 .-]{8,16}$');

/// Họ tên 2–80 ký tự, email hợp lệ, số điện thoại (nếu có) 8–16 chữ số
({String email, String fullName, String phone}) checkSignupInput(
  Object? email,
  Object? fullName,
  Object? phone,
) {
  final e = '${email ?? ''}'.trim().toLowerCase();
  final n = '${fullName ?? ''}'.trim().replaceAll(RegExp(r'\s+'), ' ');
  final p = '${phone ?? ''}'.trim();
  if (!_email.hasMatch(e)) {
    throw const SignupViolation(400, 'invalid_email', 'Email is not valid');
  }
  if (n.length < 2 || n.length > 80) {
    throw const SignupViolation(400, 'invalid_name', 'Full name 2-80 chars');
  }
  if (p.isNotEmpty && !_phone.hasMatch(p)) {
    throw const SignupViolation(400, 'invalid_phone', 'Phone is not valid');
  }
  return (email: e, fullName: n, phone: p);
}

/// Mật khẩu ít nhất 8 ký tự, có chữ và số
void checkPassword(Object? password) {
  final p = '${password ?? ''}';
  if (p.length < 8 ||
      !RegExp('[A-Za-z]').hasMatch(p) ||
      !RegExp('[0-9]').hasMatch(p)) {
    throw const SignupViolation(
      400,
      'weak_password',
      'Password needs 8+ chars with letters and digits',
    );
  }
}

String hashSignupCode(String email, String code) =>
    sha256.convert(utf8.encode('$email:$code')).toString();

/// Nội dung email mã xác nhận theo ngôn ngữ app
({String subject, String body}) signupEmail(String language, String code) =>
    switch (language) {
      'vi' => (
        subject: 'TBT Center: mã xác nhận $code',
        body:
            'Mã xác nhận đăng ký tài khoản TBT Center của bạn là $code.\n\n'
            'Mã có hiệu lực 10 phút. Nếu bạn không đăng ký, hãy bỏ qua email '
            'này.',
      ),
      'de' => (
        subject: 'TBT Center: Bestätigungscode $code',
        body:
            'Ihr Bestätigungscode für TBT Center lautet $code.\n\n'
            'Der Code ist 10 Minuten gültig.',
      ),
      'pt' => (
        subject: 'TBT Center: código de confirmação $code',
        body:
            'Seu código de confirmação da TBT Center é $code.\n\n'
            'O código vale por 10 minutos.',
      ),
      _ => (
        subject: 'TBT Center: verification code $code',
        body:
            'Your TBT Center verification code is $code.\n\n'
            'The code is valid for 10 minutes. If you did not sign up, ignore '
            'this email.',
      ),
    };

/// Đăng ký ứng viên: gửi mã 6 số về email, nhập đúng mã mới tạo tài khoản
class Signup {
  Signup(this._db, {required this.identity, required this.send, Random? random})
    : _random = random ?? Random.secure();

  final Database _db;
  final IdentityAdmin identity;
  final SendMail? send;
  final Random _random;

  Future<void> sendCode({
    required Object? email,
    required Object? fullName,
    required Object? phone,
    String language = 'en',
  }) async {
    final input = checkSignupInput(email, fullName, phone);
    final mail = send;
    if (mail == null || !identity.configured) {
      throw const SignupViolation(
        503,
        'signup_unavailable',
        'Mail or identity service is not configured',
      );
    }
    if (await identity.emailTaken(input.email)) {
      throw const SignupViolation(409, 'email_taken', 'Email already used');
    }
    final last = await _db.query(
      'select last_sent_at from signup_codes where email = @email',
      params: {'email': input.email},
      fromPrimary: true,
    );
    if (last.isNotEmpty &&
        DateTime.now().difference(last.first['last_sent_at'] as DateTime) <
            signupResendGap) {
      throw const SignupViolation(429, 'code_too_soon', 'Wait before resend');
    }
    final code = (_random.nextInt(900000) + 100000).toString();
    await _db.execute(
      'insert into signup_codes (email, code_hash, full_name, phone, '
      'expires_at) values (@email, @hash, @name, @phone, @expires) '
      'on conflict (email) do update set code_hash = excluded.code_hash, '
      'full_name = excluded.full_name, phone = excluded.phone, attempts = 0, '
      'expires_at = excluded.expires_at, last_sent_at = now()',
      params: {
        'email': input.email,
        'hash': hashSignupCode(input.email, code),
        'name': input.fullName,
        'phone': input.phone,
        'expires': DateTime.now().add(signupCodeTtl).toUtc(),
      },
    );
    final message = signupEmail(language, code);
    await mail(input.email, message.subject, message.body);
  }

  /// Đúng mã thì tạo tài khoản ứng viên trong Keycloak với mật khẩu đã chọn
  Future<void> verify({
    required Object? email,
    required Object? code,
    required Object? password,
  }) async {
    final e = '${email ?? ''}'.trim().toLowerCase();
    checkPassword(password);
    final pending = await _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'select code_hash, full_name, phone, attempts, expires_at '
          'from signup_codes where email = @email for update',
        ),
        parameters: {'email': e},
      );
      if (rows.isEmpty) {
        throw const SignupViolation(404, 'code_not_found', 'Ask for a code');
      }
      final r = rows.first.toColumnMap();
      if ((r['expires_at'] as DateTime).isBefore(DateTime.now()) ||
          (r['attempts'] as int) >= signupMaxAttempts) {
        throw const SignupViolation(410, 'code_expired', 'Ask for a new code');
      }
      if (r['code_hash'] != hashSignupCode(e, '${code ?? ''}'.trim())) {
        await tx.execute(
          Sql.named(
            'update signup_codes set attempts = attempts + 1 '
            'where email = @email',
          ),
          parameters: {'email': e},
        );
        return null;
      }
      return (fullName: r['full_name'] as String, phone: r['phone'] as String);
    });
    if (pending == null) {
      throw const SignupViolation(400, 'wrong_code', 'Code does not match');
    }
    try {
      await identity.createCandidate(
        email: e,
        fullName: pending.fullName,
        phone: pending.phone,
        password: '$password',
      );
    } on IdentityException catch (error) {
      if (error.message.contains('already used')) {
        throw const SignupViolation(409, 'email_taken', 'Email already used');
      }
      throw SignupViolation(502, 'identity_unavailable', error.message);
    }
    await _db.execute(
      'delete from signup_codes where email = @email',
      params: {'email': e},
    );
  }
}
