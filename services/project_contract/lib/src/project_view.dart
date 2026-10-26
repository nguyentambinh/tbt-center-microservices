/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:project_contract_service/src/project_rules.dart';
import 'package:tbt_common/tbt_common.dart';

/// Tỷ giá 1 USD = ? [currency]
typedef RateLookup = Future<double> Function(String currency);

/// Tỷ giá dự phòng khi service currency không trả lời (chỉ để phân cấp)
const fallbackRates = {
  'USD': 1.0,
  'VND': 25400.0,
  'EUR': 0.92,
  'BRL': 5.6,
  'ZAR': 18.0,
  'AUD': 1.52,
};

/// Hỏi currency, nhớ 1 giờ; lỗi thì dùng [fallbackRates]
RateLookup currencyRates(InternalClient currency) {
  final cache = <String, ({double rate, DateTime at})>{};
  return (code) async {
    final key = code.toUpperCase();
    final hit = cache[key];
    if (hit != null && DateTime.now().difference(hit.at).inHours < 1) {
      return hit.rate;
    }
    try {
      final body = await currency.get(
        '/internal/rate',
        query: {'quote': key},
      );
      final rate = double.parse('${body['rate']}');
      cache[key] = (rate: rate, at: DateTime.now());
      return rate;
    } on Object {
      return fallbackRates[key] ?? 1;
    }
  };
}

/// Tên nhân viên theo mã (lấy từ hr, nhớ 10 phút)
typedef EmployeeNames = Future<Map<String, String>> Function();

EmployeeNames employeeNames(
  Future<List<Map<String, dynamic>>> Function() load,
) {
  ({Map<String, String> names, DateTime at})? cached;
  return () async {
    final c = cached;
    if (c != null && DateTime.now().difference(c.at).inMinutes < 10) {
      return c.names;
    }
    try {
      final names = {
        for (final e in await load())
          if (e['id'] case final String id) id: '${e['name'] ?? id}',
      };
      cached = (names: names, at: DateTime.now());
      return names;
    } on Object {
      return c?.names ?? const {};
    }
  };
}

/// Thêm phân cấp, tiến độ, mức cảnh báo vào dự án trả cho app
Map<String, dynamic> decorateProject(
  Map<String, dynamic> p, {
  required double rateToUsd,
  required DateTime today,
}) {
  final start = DateTime.tryParse('${p['startDate']}');
  final end = DateTime.tryParse('${p['endDate']}');
  final status = p['status'] as String? ?? 'in_progress';
  final value = double.tryParse('${p['expectedAcceptance']}') ?? 0;
  return {
    ...p,
    'tier': projectTier(value / rateToUsd),
    'valueUsd': (value / rateToUsd).roundToDouble(),
    'progress': progressOf(
      start: start,
      end: end,
      status: status,
      today: today,
      actualPercent: p['progressPercent'] as int?,
    ),
    'warning': warningLevel(
      start: start,
      end: end,
      status: status,
      today: today,
    ),
  };
}
