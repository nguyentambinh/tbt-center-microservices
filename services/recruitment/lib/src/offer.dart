/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';

import 'package:tbt_common/tbt_common.dart';

/// Phòng ban và chức vụ từng người ở hr
typedef LoadPlacement = Future<Map<String, dynamic>> Function();

/// Lương cơ bản của nhiều người ở payroll
typedef LoadSalaries = Future<List<Map<String, dynamic>>> Function(
  List<String> employeeIds,
);

/// Đặt lương thỏa thuận cho nhân viên mới ở payroll
typedef SetSalary = Future<void> Function(
  String employeeId, {
  required double baseSalary,
  required String currency,
  required String employmentType,
});

LoadPlacement hrPlacement(InternalClient hr) =>
    () => hr.get('/internal/placement');

LoadSalaries payrollSalaries(InternalClient payroll) => (ids) async {
  final body = await payroll.post('/internal/salary-lookup', {
    'employeeIds': ids,
  });
  return (body['items'] as List).cast<Map<String, dynamic>>();
};

SetSalary payrollSetSalary(InternalClient payroll) =>
    (
      id, {
      required baseSalary,
      required currency,
      required employmentType,
    }) => payroll.put('/internal/salaries/${Uri.encodeComponent(id)}', {
      'baseSalary': baseSalary,
      'currency': currency,
      'employmentType': employmentType,
    });

double? median(List<double> values) {
  if (values.isEmpty) return null;
  final sorted = [...values]..sort();
  final mid = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[mid]
      : (sorted[mid - 1] + sorted[mid]) / 2;
}

/// Gợi ý phòng ban, mức lương cho ứng viên đã phỏng vấn: AI chọn trong danh
/// sách thật của khu vực, lỗi thì theo người cùng chức vụ
class OfferAdvisor {
  OfferAdvisor({
    required this.placement,
    required this.salaries,
    required this.ai,
  });

  final LoadPlacement placement;
  final LoadSalaries salaries;
  final StructuredAi ai;

  static const _schema = {
    'type': 'object',
    'properties': {
      'departmentId': {'type': 'string'},
      'baseSalary': {'type': 'number'},
      'reason': {'type': 'string'},
    },
    'required': ['departmentId', 'baseSalary', 'reason'],
  };

  Future<Map<String, dynamic>> suggest(
    Map<String, dynamic> candidate, {
    required String language,
  }) async {
    final data = await placement();
    final departments = (data['departments'] as List)
        .cast<Map<String, dynamic>>();
    final employees = (data['employees'] as List).cast<Map<String, dynamic>>();
    final position = (candidate['appliedPosition'] as String? ?? '')
        .trim()
        .toLowerCase();
    final peers = [
      for (final e in employees)
        if ((e['position'] as String? ?? '').toLowerCase() == position) e,
    ];
    final pay = await salaries([
      for (final e in peers.isEmpty ? employees : peers) e['id'] as String,
    ]);
    final rules = heuristic(departments, peers, pay);
    final options = [
      for (final d in departments)
        {
          'id': d['id'],
          'name': d['name'],
          'company': d['company'],
          'members': d['members'],
        },
    ];
    if (!ai.configured || departments.isEmpty) {
      return {...rules, 'departments': options, 'source': 'rules'};
    }

    final result = await ai.generate(
      system:
          'You are an HR assistant. Pick the best department for a newly '
          'interviewed candidate and a fair monthly base salary, using only '
          'the given departments and peer salaries. Reply in $language.',
      user: jsonEncode({
        'candidate': {
          'appliedPosition': candidate['appliedPosition'],
          'aiSummary': candidate['aiSummary'],
        },
        'departments': options,
        'peerPositions': {
          for (final e in peers) e['id']: e['departmentId'],
        },
        'peerSalaries': [for (final s in pay) s['baseSalary']],
        'currency': rules['currency'],
        'ruleSuggestion': rules,
      }),
      schema: _schema,
    );
    final ids = {for (final d in departments) d['id']};
    final salary = (result?['baseSalary'] as num?)?.toDouble();
    if (result == null ||
        !ids.contains(result['departmentId']) ||
        salary == null ||
        salary <= 0) {
      return {...rules, 'departments': options, 'source': 'rules'};
    }
    return {
      'departmentId': result['departmentId'],
      'baseSalary': salary.roundToDouble(),
      'currency': rules['currency'],
      'reason': result['reason'],
      'peerMedian': rules['peerMedian'],
      'departments': options,
      'source': ai.lastProvider ?? 'ai',
    };
  }

  /// Phòng có nhiều người cùng chức vụ nhất, lương trung vị của họ
  static Map<String, dynamic> heuristic(
    List<Map<String, dynamic>> departments,
    List<Map<String, dynamic>> peers,
    List<Map<String, dynamic>> pay,
  ) {
    final counts = <String, int>{};
    for (final p in peers) {
      final d = p['departmentId'] as String?;
      if (d != null) counts[d] = (counts[d] ?? 0) + 1;
    }
    String? department;
    if (counts.isNotEmpty) {
      department =
          (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;
    } else if (departments.isNotEmpty) {
      department =
          (departments.toList()..sort(
                    (a, b) => (b['members'] as int? ?? 0).compareTo(
                      a['members'] as int? ?? 0,
                    ),
                  ))
                  .first['id']
              as String;
    }
    final currencies = <String, int>{};
    for (final s in pay) {
      final c = s['currency'] as String;
      currencies[c] = (currencies[c] ?? 0) + 1;
    }
    final currency = currencies.isEmpty
        ? null
        : (currencies.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;
    final mid = median([
      for (final s in pay)
        if (s['currency'] == currency)
          double.tryParse('${s['baseSalary']}') ?? 0,
    ]);
    return {
      'departmentId': department,
      'baseSalary': mid?.roundToDouble(),
      'currency': currency,
      'reason': peers.isEmpty ? 'region_median' : 'peer_median',
      'peerMedian': mid?.roundToDouble(),
    };
  }
}
