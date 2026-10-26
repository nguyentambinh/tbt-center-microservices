/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/identity/keycloak_admin.dart';
import 'package:recruitment_service/src/mail_sender.dart';
import 'package:recruitment_service/src/offer.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tạo nhân viên bên hr
typedef CreateEmployee = Future<String> Function(Map<String, Object?> body);

class HiringRuleViolation implements Exception {
  const HiringRuleViolation(this.statusCode, this.code, this.message);

  final int statusCode;
  final String code;
  final String message;
}

typedef HireResult = ({
  Map<String, dynamic> candidate,
  String employeeId,
  String login,
  String? temporaryPassword,
  bool salarySet,
});

/// Thỏa thuận lúc nhận việc: phòng ban, lương cơ bản
typedef HireOffer = ({
  String? departmentId,
  double? baseSalary,
  String? currency,
  String employmentType,
});

/// Tuyển dụng: nhận ứng viên vào làm
class Hiring {
  Hiring({
    required this.candidates,
    required this.identity,
    required this.createEmployee,
    required this.region,
    this.setSalary,
    this.mail,
  });

  final CandidateRepository candidates;
  final IdentityAdmin identity;
  final CreateEmployee createEmployee;
  final String region;

  /// Lỗi đặt lương không chặn nhận việc, HR nhập lại ở màn lương
  final SetSalary? setSalary;

  /// Gửi nhân viên mới mã nhân viên, tên đăng nhập, mật khẩu
  final SendMail? mail;

  Future<HireResult?> hire(
    String id, {
    required String hiredBy,
    HireOffer? offer,
  }) async {
    final candidate = await candidates.findById(id);
    if (candidate == null) return null;
    final status = candidate['status'] as String;
    if (status != 'interviewed' && status != 'hired') {
      throw const HiringRuleViolation(
        409,
        'not_interviewed',
        'Upload the interview minutes before hiring',
      );
    }
    final salary = offer?.baseSalary;
    if (salary != null && (salary <= 0 || (offer?.currency ?? '').isEmpty)) {
      throw const HiringRuleViolation(
        400,
        'invalid_offer',
        'Salary must be positive with a currency',
      );
    }
    final email = (candidate['email'] as String?)?.trim() ?? '';
    if (email.isEmpty) {
      throw const HiringRuleViolation(
        422,
        'email_required',
        'Candidate needs an email to sign in',
      );
    }
    if (!identity.configured) {
      throw const HiringRuleViolation(
        503,
        'identity_not_configured',
        'KEYCLOAK_IDENTITY_SECRET is not set',
      );
    }

    final country = candidate['countryCode'] as String;
    final name = splitName(candidate['fullName'] as String, country);
    final employeeId = await createEmployee({
      'id': employeeIdFor(id),
      'countryCode': country,
      'familyName': name.family,
      'givenName': name.given,
      'email': email,
      'phone': candidate['phone'],
      'position': candidate['appliedPosition'],
      'departmentId': ?offer?.departmentId,
    });

    final GrantedAccount account;
    try {
      account = await identity.grantEmployee(
        StaffAccount(
          email: email,
          firstName: name.given,
          lastName: name.family,
          region: region,
          countryCode: country,
          employeeId: employeeId,
        ),
        subject: await candidates.subjectOf(id),
      );
    } on IdentityException catch (e) {
      throw HiringRuleViolation(502, 'identity_unavailable', e.message);
    }

    var salarySet = false;
    if (setSalary != null && salary != null) {
      try {
        await setSalary!(
          employeeId,
          baseSalary: salary,
          currency: offer!.currency!,
          employmentType: offer.employmentType,
        );
        salarySet = true;
      } on InternalCallException {
        salarySet = false;
      }
    }

    final hired = await candidates.markHired(
      id,
      employeeId: employeeId,
      changedBy: hiredBy,
      subject: account.subject,
      departmentId: offer?.departmentId,
      salary: salary,
      currency: offer?.currency,
    );
    if ((mail, account.temporaryPassword) case (final send?, final password?)) {
      final message = welcomeEmail(
        country,
        name: candidate['fullName'] as String,
        employeeId: employeeId,
        login: email,
        password: password,
      );
      await send(email, message.subject, message.body);
    }
    return (
      candidate: hired ?? candidate,
      employeeId: employeeId,
      login: email,
      temporaryPassword: account.temporaryPassword,
      salarySet: salarySet,
    );
  }
}

/// Email chào nhân viên mới kèm thông tin đăng nhập, theo ngôn ngữ nước
({String subject, String body}) welcomeEmail(
  String country, {
  required String name,
  required String employeeId,
  required String login,
  required String password,
}) => switch (country) {
  'VN' => (
    subject: 'TBT Center: chào mừng bạn vào làm, thông tin đăng nhập',
    body:
        'Chào $name,\n\nChúc mừng bạn chính thức là nhân viên TBT Center.\n\n'
        'Mã nhân viên: $employeeId\nTên đăng nhập: $login\n'
        'Mật khẩu: $password\n\n'
        'Hãy đăng nhập app TBT Center rồi đổi mật khẩu ở mục Cá nhân > '
        'Đổi mật khẩu.',
  ),
  'DE' => (
    subject: 'TBT Center: Willkommen, Ihre Zugangsdaten',
    body:
        'Hallo $name,\n\nwillkommen bei TBT Center.\n\n'
        'Personalnummer: $employeeId\nBenutzername: $login\n'
        'Passwort: $password\n\n'
        'Bitte melden Sie sich in der App an und ändern Sie das Passwort '
        'unter Persönlich > Passwort ändern.',
  ),
  'BR' => (
    subject: 'TBT Center: boas-vindas e dados de acesso',
    body:
        'Olá $name,\n\nbem-vindo(a) à TBT Center.\n\n'
        'Matrícula: $employeeId\nUsuário: $login\nSenha: $password\n\n'
        'Entre no app e troque a senha em Pessoal > Alterar senha.',
  ),
  _ => (
    subject: 'TBT Center: welcome aboard, your sign-in details',
    body:
        'Hello $name,\n\nwelcome to TBT Center.\n\n'
        'Employee ID: $employeeId\nUsername: $login\nPassword: $password\n\n'
        'Sign in to the app and change your password under Personal > '
        'Change password.',
  ),
};

/// Mã nhân viên cố định theo ứng viên
String employeeIdFor(String candidateId) =>
    'TBT${candidateId.replaceAll('-', '').substring(0, 8).toUpperCase()}';

/// VN: họ trước tên sau, nước khác ngược lại
({String family, String given}) splitName(String fullName, String country) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return (family: '', given: parts.single);
  if (country == 'VN') {
    return (
      family: parts.sublist(0, parts.length - 1).join(' '),
      given: parts.last,
    );
  }
  return (family: parts.sublist(1).join(' '), given: parts.first);
}

CreateEmployee hrEmployees(InternalClient hr) => (body) async {
  final created = await hr.post('/internal/employees', body);
  return created['id'] as String;
};
