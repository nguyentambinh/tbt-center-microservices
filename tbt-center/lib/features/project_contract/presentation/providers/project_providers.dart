/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/work_region.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final region = ref.watch(workRegionProvider);
  return ProjectRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

/// Ô tìm kiếm trên màn danh sách dự án.
final projectSearchProvider = NotifierProvider<ProjectSearch, String>(ProjectSearch.new);

class ProjectSearch extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value.trim();
}

/// Lọc theo phân cấp dự án (1..4), null là mọi cấp
final projectTierProvider = NotifierProvider<ProjectTier, int?>(ProjectTier.new);

class ProjectTier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? value) => state = value;
}

/// Lọc theo khoảng thời gian: dự án có thời gian chạy chồng lên khoảng này
final projectRangeProvider = NotifierProvider<ProjectRange, DateTimeRange?>(ProjectRange.new);

class ProjectRange extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void set(DateTimeRange? value) => state = value;
}

final projectsProvider = FutureProvider<List<ProjectSummary>>(
  (ref) => ref.watch(projectRepositoryProvider).projects(search: ref.watch(projectSearchProvider), tier: ref.watch(projectTierProvider), range: ref.watch(projectRangeProvider)),
);

/// Ban lãnh đạo duyệt đề xuất của từng khu vực
final regionProjectRepositoryProvider = Provider.family<ProjectRepository, String>(
  (ref, region) => ProjectRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region)),
);

final proposalsProvider = FutureProvider.autoDispose.family<List<ProjectProposal>, ({String region, String? status})>(
  (ref, q) => ref.watch(regionProjectRepositoryProvider(q.region)).proposals(status: q.status),
);

final proposalDetailProvider = FutureProvider.autoDispose.family<ProjectProposal, ({String region, int id})>(
  (ref, q) => ref.watch(regionProjectRepositoryProvider(q.region)).proposal(q.id),
);

/// Số đề xuất đang chờ Ban lãnh đạo ở mọi khu vực
final pendingProposalsProvider = FutureProvider.autoDispose<int>((ref) async {
  final repositories = [for (final region in Env.regions) ref.watch(regionProjectRepositoryProvider(region))];
  var total = 0;
  for (final repository in repositories) {
    try {
      total += (await repository.proposals(status: 'awaiting_executive')).length;
    } on Object {
      // Khu vực đang tắt thì bỏ qua
    }
  }
  return total;
});

final projectDetailProvider = FutureProvider.family<ProjectDetail, String>(
  (ref, id) => ref.watch(projectRepositoryProvider).project(id),
);

final myProjectsProvider = FutureProvider<List<MyProject>>((ref) => ref.watch(projectRepositoryProvider).myProjects());
