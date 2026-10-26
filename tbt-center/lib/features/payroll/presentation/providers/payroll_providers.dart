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
import '../../data/repositories/payroll_repository_impl.dart';
import '../../domain/entities/payroll.dart';
import '../../domain/repositories/payroll_repository.dart';

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final region = ref.watch(workRegionProvider);
  return PayrollRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final myPayrollProvider = FutureProvider<PayrollSummary>((ref) => ref.watch(payrollRepositoryProvider).myPayroll());

/// Ban điều hành duyệt đề xuất tăng lương của từng khu vực
final regionPayrollRepositoryProvider = Provider.family<PayrollRepository, String>(
  (ref, region) => PayrollRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region)),
);

final raiseRequestsProvider = FutureProvider.autoDispose.family<List<RaiseRequest>, ({String region, String? status})>(
  (ref, q) => ref.watch(regionPayrollRepositoryProvider(q.region)).raiseRequests(status: q.status),
);
