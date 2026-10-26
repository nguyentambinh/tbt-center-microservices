/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

/// Báo cáo khu vực gửi Ban lãnh đạo: ảnh chụp số liệu lúc gửi, cấp trên xác nhận mới gửi bản tiếp
class ReportSubmission {
  const ReportSubmission({
    required this.id,
    required this.kind,
    required this.period,
    required this.status,
    required this.data,
    required this.submittedBy,
    required this.createdAt,
    this.note,
    this.reviewedBy,
    this.reviewNote,
  });

  final int id;

  /// `hr` hoặc `finance`
  final String kind;
  final String period;

  /// submitted, acknowledged, returned
  final String status;
  final Map<String, dynamic> data;
  final String submittedBy;
  final DateTime createdAt;
  final String? note;
  final String? reviewedBy;
  final String? reviewNote;

  bool get waiting => status == 'submitted';
}
