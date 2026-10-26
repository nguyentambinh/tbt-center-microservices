/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

/// Khu vực đang làm việc: mặc định theo token; tài khoản tập đoàn chọn được nước cần xem
final workRegionProvider = NotifierProvider<WorkRegion, String>(WorkRegion.new);

class WorkRegion extends Notifier<String> {
  @override
  String build() => ref.watch(authControllerProvider.select((s) => s.value?.region)) ?? 'vn';

  void select(String region) {
    final session = ref.read(authControllerProvider).value;
    if (session != null && (session.isGroup || region == session.region)) state = region;
  }
}
