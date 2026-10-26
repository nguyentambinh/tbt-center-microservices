/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/work_region.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../data/organization_repository.dart';
import '../../domain/organization.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final region = ref.watch(workRegionProvider);
  return OrganizationRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final departmentsProvider = FutureProvider.autoDispose<List<Department>>((ref) => ref.watch(organizationRepositoryProvider).departments());

final departmentDetailProvider = FutureProvider.autoDispose.family<DepartmentDetail, String>(
  (ref, id) => ref.watch(organizationRepositoryProvider).department(id),
);

final unassignedProvider = FutureProvider.autoDispose<List<OrgPerson>>((ref) => ref.watch(organizationRepositoryProvider).unassigned());

final employeeFiltersProvider = FutureProvider.autoDispose<EmployeeFilters>((ref) => ref.watch(organizationRepositoryProvider).filters());

final rankingsProvider = FutureProvider.autoDispose.family<List<OrgPerson>, ({int months, String? departmentId})>(
  (ref, q) => ref.watch(organizationRepositoryProvider).rankings(months: q.months, departmentId: q.departmentId),
);

/// Đề cử của một khu vực; Ban lãnh đạo chọn khu vực để duyệt
final regionOrganizationProvider = Provider.family<OrganizationRepository, String>(
  (ref, region) => OrganizationRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region)),
);

final nominationsProvider = FutureProvider.autoDispose.family<List<Nomination>, ({String region, String? status})>(
  (ref, q) => ref.watch(regionOrganizationProvider(q.region)).nominations(status: q.status),
);

/// Số đề cử đang chờ duyệt ở mọi khu vực, hiện ở khối việc cần xử lý của Ban lãnh đạo
final pendingNominationsProvider = FutureProvider.autoDispose<int>((ref) async {
  final repositories = [for (final region in Env.regions) ref.watch(regionOrganizationProvider(region))];
  var total = 0;
  for (final repository in repositories) {
    try {
      total += (await repository.nominations(status: 'pending')).length;
    } on Object {
      // Khu vực đang tắt thì bỏ qua
    }
  }
  return total;
});
