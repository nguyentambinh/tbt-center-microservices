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
import '../../data/repositories/employee_repository_impl.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';

/// Gọi đúng Kong của khu vực ghi trong token, không theo IP.
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final region = ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';
  return EmployeeRepositoryImpl(ref.watch(apiClientProvider), baseUrl: Env.kongUrl(region));
});

class EmployeeListState {
  const EmployeeListState({
    this.query = '',
    this.items = const [],
    this.total = 0,
    this.page = 0,
    this.loadingMore = false,
    this.searching = false,
    this.fromCache = false,
  });

  final String query;
  final List<EmployeeSummary> items;
  final int total;
  final int page;
  final bool loadingMore;

  /// Đang tìm theo từ khóa mới, vẫn hiện kết quả cũ cho tới khi có kết quả mới.
  final bool searching;
  final bool fromCache;

  bool get hasMore => items.length < total;
}

/// Danh sách nhân viên có tìm kiếm và tải thêm từng trang.
class EmployeeListController extends AsyncNotifier<EmployeeListState> {
  EmployeeRepository get _repository => ref.read(employeeRepositoryProvider);

  @override
  Future<EmployeeListState> build() {
    ref.watch(employeeRepositoryProvider);
    return _firstPage('');
  }

  Future<void> search(String query) async {
    final current = state.value;
    if (query == current?.query) return;
    if (current != null) state = AsyncData(_copy(current, searching: true));
    state = await AsyncValue.guard(() => _firstPage(query));
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _firstPage(state.value?.query ?? ''));
  }

  /// Lỗi khi tải thêm thì giữ danh sách đang có và ném lỗi ra để màn hình báo.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(_copy(current, loadingMore: true));
    try {
      final next = await _repository.search(query: current.query, page: current.page + 1);
      state = AsyncData(EmployeeListState(
        query: current.query,
        items: [...current.items, ...next.items],
        total: next.total,
        page: next.page,
        fromCache: next.fromCache,
      ));
    } on Object {
      state = AsyncData(_copy(current));
      rethrow;
    }
  }

  Future<EmployeeListState> _firstPage(String query) async {
    final page = await _repository.search(query: query);
    return EmployeeListState(
      query: query,
      items: page.items,
      total: page.total,
      page: page.page,
      fromCache: page.fromCache,
    );
  }

  EmployeeListState _copy(EmployeeListState s, {bool loadingMore = false, bool searching = false}) =>
      EmployeeListState(
        query: s.query,
        items: s.items,
        total: s.total,
        page: s.page,
        loadingMore: loadingMore,
        searching: searching,
        fromCache: s.fromCache,
      );
}

final employeeListProvider =
    AsyncNotifierProvider<EmployeeListController, EmployeeListState>(EmployeeListController.new);

final employeeDetailProvider = FutureProvider.family<EmployeeDetail, String>(
  (ref, id) => ref.watch(employeeRepositoryProvider).find(id),
);
