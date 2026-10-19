/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:io';

import 'package:payroll_service/src/payout_desk.dart';
import 'package:payroll_service/src/payroll_repository.dart';
import 'package:payroll_service/src/saga/payroll_run_repository.dart';
import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:tbt_common/tbt_common.dart';

final _env = Platform.environment;

final database = Database.fromEnvironment();
final payrollRepository = PostgresPayrollRepository(database);
final runRepository = PostgresPayrollRunRepository(database);

InternalClient _client(
  String service,
  String fallback, {
  Duration timeout = const Duration(seconds: 20),
}) => InternalClient(
  service,
  Uri.parse(_env['${service.toUpperCase()}_URL'] ?? fallback),
  timeout: timeout,
);

final _attendance = _client('attendance', 'http://attendance:8080');
final _currency = _client('currency', 'http://currency:8080');
// Kênh chi thật mất vài giây mỗi khoản
final _integration = _client(
  'integration',
  'http://integration:8080',
  timeout: const Duration(seconds: 45),
);
final _finance = _client('finance', 'http://finance:8080');

final payrollSaga = PayrollSaga(
  repository: runRepository,
  countryCode: _env['COUNTRY_CODE'] ?? 'VN',
  lockPeriod: (period, runId) => _attendance.post('/internal/period-locks', {
    'period': period,
    'runId': runId,
  }),
  unlockPeriod: (period, runId) => _attendance.delete(
    '/internal/period-locks',
    {'period': period, 'runId': runId},
  ),
  reserveBudget: (period, runId, amount) => _finance.post(
    '/internal/payroll-budgets',
    {'period': period, 'runId': runId, 'amount': amount},
  ),
  releaseBudget: (period, runId) => _finance.post(
    '/internal/payroll-budgets/$period/release',
    {'runId': runId},
  ),
  recordExpense: (period, runId, amount, count) => _finance.post(
    '/internal/payroll-budgets/$period/expense',
    {'runId': runId, 'amount': amount, 'paidCount': count},
  ),
  region: _env['REGION'] ?? 'vn',
  hours: (period) async {
    final data = await _attendance.get(
      '/internal/hours',
      query: {'period': period},
    );
    return {
      for (final item in data['items'] as List)
        (item as Map<String, dynamic>)['employeeId'] as String:
            (item['overtimeHours'] as num).toDouble(),
    };
  },
  rate: (currency, date) async {
    final data = await _currency.get(
      '/internal/rate',
      query: {
        'quote': currency,
        'date': date.toIso8601String().substring(0, 10),
      },
    );
    return (
      rate: data['rate'] as String,
      date: DateTime.parse(data['rateDate'] as String),
    );
  },
  payout: payoutSink,
);

/// Chi qua integration (ngân hàng giả lập hoặc payOS), mỗi lời gọi một khoản
/// để kịp hạn chờ giữa hai service
Future<Map<String, String>> payoutSink(
  List<({String reference, String account, double amount, String currency})>
  items,
) async {
  final paid = <String, String>{};
  for (final item in items) {
    final chunk = [item];
    try {
      final data = await _integration.post('/internal/payouts', {
        'items': [
          for (final i in chunk)
            {
              'reference': i.reference,
              'account': i.account,
              'amount': i.amount,
              'currency': i.currency,
            },
        ],
      });
      paid.addAll(_paid(data));
    } on InternalCallException catch (e) {
      // Quá hạn, mất kết nối: không biết ngân hàng đã chuyển chưa
      if (e.statusCode == null) throw PayoutInDoubt(e.message);
      // Ngân hàng trả lời từ chối: khoản đã chuyển vẫn phải ghi nhận
      throw PayoutFailed(e.message, {...paid, ..._paid(e.body)});
    }
  }
  return paid;
}

final payoutDesk = PayoutDesk(
  store: PostgresPayoutStore(database),
  payout: payoutSink,
);

Map<String, String> _paid(Map<String, dynamic> data) => {
  for (final p in data['paid'] as List? ?? const [])
    (p as Map<String, dynamic>)['reference'] as String:
        p['bankReference'] as String,
};
