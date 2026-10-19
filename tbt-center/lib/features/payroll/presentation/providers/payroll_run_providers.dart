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
import '../../data/repositories/payroll_run_repository_impl.dart';
import '../../domain/entities/payout.dart';
import '../../domain/entities/payroll_run.dart';
import '../../domain/repositories/payroll_run_repository.dart';

/// Vai trò được chốt lương, khớp với service payroll.
const payrollRunnerRoles = {'finance', 'admin', 'executive'};

/// Lãnh đạo tập đoàn chốt, chuyển lương được ở mọi công ty (khu vực).
const groupPayrollRoles = {'executive'};

/// Repository Saga lương của một khu vực bất kỳ
final payrollRunRepositoryForRegionProvider = Provider<PayrollRunRepository Function(String region)>((ref) {
  final dio = ref.watch(apiClientProvider);
  return (region) => PayrollRunRepositoryImpl(dio, baseUrl: Env.kongUrl(region));
});

/// Công ty đang xem ở màn chốt lương; mặc định là khu vực của người dùng
final payrollRegionProvider = NotifierProvider<PayrollRegion, String>(PayrollRegion.new);

class PayrollRegion extends Notifier<String> {
  @override
  String build() => ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';

  void select(String region) => state = region;
}

final payrollRunRepositoryProvider = Provider<PayrollRunRepository>(
  (ref) => ref.watch(payrollRunRepositoryForRegionProvider)(ref.watch(payrollRegionProvider)),
);

final payrollRunsProvider = FutureProvider<List<PayrollRun>>((ref) => ref.watch(payrollRunRepositoryProvider).runs());

final payrollRunProvider = FutureProvider.family<PayrollRun, String>(
  (ref, id) => ref.watch(payrollRunRepositoryProvider).run(id),
);

final payoutBoardProvider = FutureProvider.family<PayoutBoard, String>(
  (ref, period) => ref.watch(payrollRunRepositoryProvider).payouts(period),
);

final payoutLogProvider = FutureProvider.family<List<PayoutLogItem>, String>(
  (ref, period) => ref.watch(payrollRunRepositoryProvider).payoutLog(period),
);
