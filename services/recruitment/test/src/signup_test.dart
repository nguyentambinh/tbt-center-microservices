/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:recruitment_service/src/identity/hiring.dart';
import 'package:recruitment_service/src/identity/signup.dart';
import 'package:test/test.dart';

Matcher _code(String code) => throwsA(
  isA<SignupViolation>().having((e) => e.code, 'code', code),
);

void main() {
  test('đăng ký cần email, họ tên, số điện thoại hợp lệ', () {
    final ok = checkSignupInput(
      ' Thu.Le@Gmail.com ',
      '  Lê   Minh Thư ',
      '0901 234 567',
    );
    expect(ok.email, 'thu.le@gmail.com');
    expect(ok.fullName, 'Lê Minh Thư');
    expect(
      () => checkSignupInput('khong-phai-email', 'Thư', '0901234567'),
      _code('invalid_email'),
    );
    expect(
      () => checkSignupInput('a@b.vn', 'T', '0901234567'),
      _code('invalid_name'),
    );
    expect(
      () => checkSignupInput('a@b.vn', 'Lê Thư', '12'),
      _code('invalid_phone'),
    );
  });

  test('mật khẩu ít nhất 8 ký tự, có chữ và số', () {
    expect(() => checkPassword('abc123'), _code('weak_password'));
    expect(() => checkPassword('abcdefgh'), _code('weak_password'));
    expect(() => checkPassword('Tbt2026an'), returnsNormally);
  });

  test('mã chỉ lưu dạng băm, gắn với email', () {
    final hash = hashSignupCode('a@b.vn', '123456');
    expect(hash, hasLength(64));
    expect(hash, isNot(contains('123456')));
    expect(hashSignupCode('c@d.vn', '123456'), isNot(hash));
    expect(signupEmail('vi', '123456').body, contains('123456'));
  });

  test('email nhân viên mới có mã nhân viên, tên đăng nhập, mật khẩu', () {
    final mail = welcomeEmail(
      'VN',
      name: 'Lê Minh Thư',
      employeeId: 'TBT1A2B3C4D',
      login: 'thu@example.com',
      password: 'Xk7pQ2mZ9t',
    );
    expect(mail.body, contains('TBT1A2B3C4D'));
    expect(mail.body, contains('thu@example.com'));
    expect(mail.body, contains('Xk7pQ2mZ9t'));
    expect(mail.body, contains('Đổi mật khẩu'));
  });
}
