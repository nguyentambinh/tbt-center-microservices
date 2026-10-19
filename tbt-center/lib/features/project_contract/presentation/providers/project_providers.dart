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
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return ProjectRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

/// Ô tìm kiếm trên màn danh sách dự án.
final projectSearchProvider = NotifierProvider<ProjectSearch, String>(ProjectSearch.new);

class ProjectSearch extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value.trim();
}

final projectsProvider = FutureProvider<List<ProjectSummary>>(
  (ref) => ref.watch(projectRepositoryProvider).projects(search: ref.watch(projectSearchProvider)),
);

final projectDetailProvider = FutureProvider.family<ProjectDetail, String>(
  (ref, id) => ref.watch(projectRepositoryProvider).project(id),
);

final myProjectsProvider = FutureProvider<List<MyProject>>((ref) => ref.watch(projectRepositoryProvider).myProjects());
