/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

/// Số ngày báo trước tối thiểu, khớp luật ở service hr
const resignationNoticeDays = 30;

/// Đơn xin thôi việc: pending → approved → completed, hoặc rejected / withdrawn
class Resignation {
  const Resignation({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.lastDay,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.decidedBy,
    this.note,
    this.letterName,
    this.aiAnalysis,
  });

  final int id;
  final String employeeId;
  final String name;
  final DateTime lastDay;
  final String reason;
  final String status;
  final DateTime createdAt;
  final String? decidedBy;
  final String? note;

  /// Tên tệp đơn đã nộp (ảnh, Word, PDF)
  final String? letterName;

  /// AI phân tích đơn cho cấp trên: summary, mainReasons, category, tone,
  /// retentionIdeas, concerns
  final Map<String, dynamic>? aiAnalysis;

  bool get open => status == 'pending' || status == 'approved';

  /// HR hoàn tất được khi đã tới ngày làm cuối
  bool canComplete(DateTime now) => status == 'approved' && !DateTime(now.year, now.month, now.day).isBefore(lastDay);
}
