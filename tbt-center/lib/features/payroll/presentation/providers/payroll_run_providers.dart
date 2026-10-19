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
import '../../domain/entities/payroll_run.dart';
import '../../domain/repositories/payroll_run_repository.dart';

/// Vai trò được chốt lương, khớp với service payroll.
const payrollRunnerRoles = {'finance', 'admin', 'executive'};

final payrollRunRepositoryProvider = Provider<PayrollRunRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return PayrollRunRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final payrollRunsProvider = FutureProvider<List<PayrollRun>>((ref) => ref.watch(payrollRunRepositoryProvider).runs());

final payrollRunProvider = FutureProvider.family<PayrollRun, String>(
  (ref, id) => ref.watch(payrollRunRepositoryProvider).run(id),
);
