/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/work_region.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../domain/entities/finance.dart';
import '../../domain/repositories/finance_repository.dart';

/// Ghi chứng từ, trả nhà cung cấp, chốt sổ; khớp quyền ở service finance.
const financeWriterRoles = {'finance', 'admin'};

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final region = ref.watch(workRegionProvider);
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

final financeAnalyticsProvider = FutureProvider.autoDispose.family<FinanceSeries, String>(
  (ref, granularity) => ref.watch(financeRepositoryProvider).analytics(granularity),
);

final projectRankingProvider = FutureProvider.autoDispose<List<ProjectFinance>>(
  (ref) => ref.watch(financeRepositoryProvider).projectRanking(),
);

final projectFinanceProvider = FutureProvider.autoDispose.family<ProjectFinanceDetail, String>(
  (ref, id) => ref.watch(financeRepositoryProvider).projectFinance(id),
);
