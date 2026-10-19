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
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/group_report.dart';
import '../../domain/repositories/report_repository.dart';

/// Vai trò xem báo cáo hợp nhất, khớp với service report.
const groupReportRoles = {'executive', 'admin', 'finance'};

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return ReportRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final groupReportProvider = FutureProvider<GroupReport>((ref) => ref.watch(reportRepositoryProvider).overview());
