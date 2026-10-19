/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:notification_service/src/domain/notification_rules.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tìm mã hồ sơ ứng viên của một tài khoản (hỏi recruitment).
typedef CandidateLookup = Future<String?> Function(String userSub);

/// Một người nhận thông báo theo nhiều "địa chỉ": mã nhân viên, hồ sơ ứng
/// viên, từng vai trò của họ.
class RecipientResolver {
  RecipientResolver(this._lookup);

  final CandidateLookup _lookup;

  // Mã hồ sơ ứng viên không đổi theo tài khoản, nhớ lại cho đỡ gọi recruitment.
  final _candidates = <String, String?>{};

  Future<List<String>> of(Claims claims) async {
    final recipients = [
      for (final role in claims.roles) roleRecipient(role),
      if (claims.employeeId case final id?) employeeRecipient(id),
    ];
    if (claims.hasAnyRole(const {'candidate'})) {
      final sub = claims.subject;
      final candidate = _candidates[sub] ??= await _lookup(sub);
      if (candidate != null) recipients.add(candidateRecipient(candidate));
    }
    return recipients;
  }
}

/// Hỏi recruitment qua đường nội bộ `/internal/candidate-of`.
CandidateLookup recruitmentLookup(InternalClient recruitment) =>
    (sub) async =>
        (await recruitment.get(
              '/internal/candidate-of',
              query: {'sub': sub},
            ))['candidateId']
            as String?;
