/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../domain/entities/finance.dart';
import '../../domain/repositories/finance_repository.dart';

/// Ghi chứng từ, trả nhà cung cấp, chốt sổ; khớp quyền ở service finance.
const financeWriterRoles = {'finance', 'admin'};

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return FinanceRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final financeYearProvider = NotifierProvider<FinanceYearSelection, int>(FinanceYearSelection.new);

class FinanceYearSelection extends Notifier<int> {
  @override
  int build() => DateTime.now().year;

  void previous() => state--;

  void next() {
    if (state < DateTime.now().year) state++;
  }
}

final financeSummaryProvider = FutureProvider<FinanceYear>(
  (ref) => ref.watch(financeRepositoryProvider).year(ref.watch(financeYearProvider)),
);

final suppliersProvider = FutureProvider<List<Supplier>>((ref) => ref.watch(financeRepositoryProvider).suppliers());

final supplierDetailProvider = FutureProvider.family<SupplierDetail, String>(
  (ref, id) => ref.watch(financeRepositoryProvider).supplier(id),
);
