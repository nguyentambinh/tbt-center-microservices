/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/api_client.dart';
import '../../../hr/domain/entities/employee.dart';
import '../../data/profile_repository.dart';
import '../../domain/change_request.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return ProfileRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

final myProfileProvider = FutureProvider.autoDispose<EmployeeDetail>((ref) => ref.watch(profileRepositoryProvider).me());

final myChangeRequestsProvider =
    FutureProvider.autoDispose<List<ChangeRequest>>((ref) => ref.watch(profileRepositoryProvider).myRequests());

/// HR: danh sách đề xuất theo trạng thái lọc
final changeRequestsProvider = FutureProvider.autoDispose.family<List<ChangeRequest>, String?>(
  (ref, status) => ref.watch(profileRepositoryProvider).requests(status: status),
);
