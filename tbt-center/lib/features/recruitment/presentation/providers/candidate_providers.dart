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
import '../../../../core/locale/locale_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/candidate_import_repository_impl.dart';
import '../../data/repositories/candidate_repository_impl.dart';
import '../../domain/entities/candidate.dart';
import '../../domain/entities/candidate_import.dart';
import '../../domain/repositories/candidate_import_repository.dart';
import '../../domain/repositories/candidate_repository.dart';

const recruiterRoles = {'hr', 'admin', 'executive'};

/// Nhân viên dùng khu vực trong token; ứng viên chưa có khu vực thì nộp về
/// khu vực dò theo IP (đổi được trong Cài đặt khi giả lập vị trí).
final candidateRepositoryProvider = Provider<CandidateRepository>((ref) {
  final String? tokenRegion = ref.watch(authControllerProvider.select((s) => s.value?.claims['region'] as String?));
  final String region = tokenRegion ?? ref.watch(submitRegionProvider);
  return CandidateRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final myApplicationProvider = FutureProvider<Candidate?>(
  (ref) => ref.watch(candidateRepositoryProvider).myApplication(),
);

final candidateListProvider = FutureProvider.family<List<Candidate>, String?>(
  (ref, status) => ref.watch(candidateRepositoryProvider).candidates(status: status),
);

final candidateDetailProvider = FutureProvider.family<Candidate, String>(
  (ref, id) => ref.watch(candidateRepositoryProvider).candidate(id),
);

final candidateImportRepositoryProvider = Provider<CandidateImportRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return CandidateImportRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final candidateImportProvider = FutureProvider.family<CandidateImport, String>(
  (ref, id) => ref.watch(candidateImportRepositoryProvider).find(id),
);
