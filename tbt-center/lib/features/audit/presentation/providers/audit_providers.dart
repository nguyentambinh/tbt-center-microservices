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
import '../../data/repositories/audit_repository_impl.dart';
import '../../domain/entities/audit.dart';
import '../../domain/repositories/audit_repository.dart';

/// Khớp với service audit: đọc sổ, và xem nhật ký truy cập.
const auditReaderRoles = {'executive', 'admin', 'auditor'};
const accessLogRoles = {'executive', 'admin'};

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return AuditRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final auditEventsProvider = FutureProvider.autoDispose.family<List<AuditEvent>, AuditQuery>(
  (ref, query) => ref.watch(auditRepositoryProvider).events(query),
);

final auditStatsProvider = FutureProvider.autoDispose.family<AuditStats, AuditQuery>(
  (ref, query) => ref.watch(auditRepositoryProvider).stats(query),
);

final auditAccessLogProvider = FutureProvider.autoDispose<List<AccessEntry>>(
  (ref) => ref.watch(auditRepositoryProvider).accessLog(),
);
