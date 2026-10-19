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
import '../../data/repositories/payroll_repository_impl.dart';
import '../../domain/entities/payroll.dart';
import '../../domain/repositories/payroll_repository.dart';

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return PayrollRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final myPayrollProvider = FutureProvider<PayrollSummary>((ref) => ref.watch(payrollRepositoryProvider).myPayroll());
