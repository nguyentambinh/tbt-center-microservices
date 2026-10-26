/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/auth/work_region.dart';
import '../../../../core/config/env.dart';
import '../../../../core/locale/locale_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/candidate_import_repository_impl.dart';
import '../../data/repositories/candidate_repository_impl.dart';
import '../../data/repositories/job_position_repository.dart';
import '../../domain/entities/candidate.dart';
import '../../domain/entities/candidate_import.dart';
import '../../domain/entities/job_position.dart';
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

/// Cùng khu vực với nơi ứng viên nộp hồ sơ
final jobPositionRepositoryProvider = Provider<JobPositionRepository>((ref) {
  final String? tokenRegion = ref.watch(authControllerProvider.select((s) => s.value?.claims['region'] as String?));
  final String region = tokenRegion ?? ref.watch(submitRegionProvider);
  return JobPositionRepository(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

/// Vị trí còn nhận hồ sơ, cho ứng viên tick chọn
final openPositionsProvider = FutureProvider.autoDispose<List<JobPosition>>(
  (ref) => ref.watch(jobPositionRepositoryProvider).list(),
);

/// Mọi vị trí kể cả đã đóng, cho HR quản lý
final allPositionsProvider = FutureProvider.autoDispose<List<JobPosition>>(
  (ref) => ref.watch(jobPositionRepositoryProvider).list(all: true),
);

final positionDetailProvider = FutureProvider.autoDispose.family<JobPosition, int>(
  (ref, id) => ref.watch(jobPositionRepositoryProvider).find(id),
);

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
  final region = ref.watch(workRegionProvider);
  return CandidateImportRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final candidateImportProvider = FutureProvider.family<CandidateImport, String>(
  (ref, id) => ref.watch(candidateImportRepositoryProvider).find(id),
);
