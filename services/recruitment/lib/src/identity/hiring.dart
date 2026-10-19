/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:recruitment_service/src/identity/keycloak_admin.dart';
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
});

/// Tuyển dụng: nhận ứng viên vào làm
class Hiring {
  Hiring({
    required this.candidates,
    required this.identity,
    required this.createEmployee,
    required this.region,
  });

  final CandidateRepository candidates;
  final IdentityAdmin identity;
  final CreateEmployee createEmployee;
  final String region;

  Future<HireResult?> hire(String id, {required String hiredBy}) async {
    final candidate = await candidates.findById(id);
    if (candidate == null) return null;
    final status = candidate['status'] as String;
    if (status != 'offered' && status != 'hired') {
      throw const HiringRuleViolation(
        409,
        'not_offered',
        'Only offered candidates can be hired',
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

    final hired = await candidates.markHired(
      id,
      employeeId: employeeId,
      changedBy: hiredBy,
      subject: account.subject,
    );
    return (
      candidate: hired ?? candidate,
      employeeId: employeeId,
      login: email,
      temporaryPassword: account.temporaryPassword,
    );
  }
}

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
