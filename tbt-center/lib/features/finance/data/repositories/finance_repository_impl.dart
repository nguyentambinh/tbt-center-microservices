/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:dio/dio.dart';

import '../../../../core/error/app_failure.dart';
import '../../domain/entities/finance.dart';
import '../../domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl(this._dio, {required String baseUrl}) : _root = '$baseUrl/finance';

  final Dio _dio;
  final String _root;

  @override
  Future<FinanceYear> year(int year) async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_root/summary', queryParameters: {'year': year}));
    return FinanceYear(
      year: year,
      currency: d['currency'] as String,
      months: [
        for (final m in d['months'] as List)
          MonthFigures(
            period: (m as Map<String, dynamic>)['period'] as String,
            revenue: _number(m['revenue']),
            revenueUsd: _number(m['revenueUsd']),
            cost: _number(m['cost']),
            costUsd: _number(m['costUsd']),
            closedAt: DateTime.tryParse(m['closedAt'] as String? ?? ''),
          ),
      ],
    );
  }

  @override
  Future<List<Supplier>> suppliers() async {
    final d = await _call(() => _dio.get<Map<String, dynamic>>('$_root/suppliers'));
    return [for (final s in d['items'] as List) _supplier(s as Map<String, dynamic>)];
  }

  @override
  Future<SupplierDetail> supplier(String id) async {
    final d = await _call(
      () => _dio.get<Map<String, dynamic>>('$_root/suppliers/${Uri.encodeComponent(id)}'),
    );
    List<LedgerEntry> entries(String key, String labelKey) => [
          for (final e in d[key] as List)
            LedgerEntry(
              date: DateTime.parse((e as Map<String, dynamic>)['date'] as String),
              amount: _number(e['amount']),
              currency: e['currency'] as String,
              label: e[labelKey] as String?,
            ),
        ];
    return SupplierDetail(
      supplier: _supplier(d),
      imports: entries('imports', 'materialName'),
      payments: entries('payments', 'note'),
    );
  }

  @override
  Future<void> recordPurchase({
    required String supplierId,
    required String materialName,
    required DateTime date,
    required String amount,
  }) =>
      _call(() => _dio.post<Map<String, dynamic>>('$_root/material-imports', data: {
            'supplierId': supplierId,
            'materialName': materialName,
            'importedOn': _day(date),
            'amount': amount,
          }));

  @override
  Future<void> recordPayment({required String supplierId, required DateTime date, required String amount, String? note}) =>
      _call(() => _dio.post<Map<String, dynamic>>(
            '$_root/suppliers/${Uri.encodeComponent(supplierId)}/payments',
            data: {'paidOn': _day(date), 'amount': amount, if (note != null && note.isNotEmpty) 'note': note},
          ));

  @override
  Future<void> closePeriod(String period) => _call(() => _dio.post<Map<String, dynamic>>('$_root/periods/$period/close'));

  Future<Map<String, dynamic>> _call(Future<Response<Map<String, dynamic>>> Function() send) async {
    try {
      return (await send()).data ?? const {};
    } on DioException catch (e) {
      throw e.error is AppFailure ? e.error! : AppFailure.fromDio(e);
    }
  }

  static Supplier _supplier(Map<String, dynamic> s) => Supplier(
        id: s['id'] as String,
        name: s['name'] as String,
        contact: s['contact'] as String?,
        address: s['address'] as String?,
        purchased: _number(s['purchased']),
        paid: _number(s['paid']),
        balance: _number(s['balance']),
        lastImport: DateTime.tryParse(s['lastImport'] as String? ?? ''),
        purchases: (s['purchases'] as num?)?.toInt() ?? 0,
        paidPercent: (s['paidPercent'] as num?)?.toDouble(),
      );

  static double _number(Object? value) => double.tryParse('$value') ?? 0;

  static String _day(DateTime d) => d.toIso8601String().substring(0, 10);
}
