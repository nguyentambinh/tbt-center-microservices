/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/project.dart';

abstract interface class ProjectRepository {
  Future<List<ProjectSummary>> projects({String? search});

  Future<ProjectDetail> project(String id);

  Future<List<MyProject>> myProjects();

  /// Nghiệm thu: server ghi doanh thu ở tài chính rồi đổi trạng thái dự án (R100).
  Future<ProjectDetail> accept(String id);
}
