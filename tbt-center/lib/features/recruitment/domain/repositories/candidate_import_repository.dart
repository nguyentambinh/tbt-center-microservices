/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import '../entities/candidate_import.dart';

/// HR nhập ứng viên hàng loạt từ tệp `.csv`, `.xlsx`.
abstract interface class CandidateImportRepository {
  /// Gửi tệp, nhận lại danh sách nháp; chưa có hồ sơ nào được ghi.
  Future<CandidateImport> upload(String fileName, List<int> bytes);

  Future<CandidateImport> find(String id);

  /// [rowIds] `null` là xác nhận mọi dòng hợp lệ còn chờ. Trả số dòng đã ghi.
  Future<({int accepted, CandidateImport draft})> confirm(String id, {List<String>? rowIds});
}
