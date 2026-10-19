/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Một dòng nháp trong tệp HR tải lên (R84).
class ImportRow {
  const ImportRow({
    required this.id,
    required this.rowNumber,
    required this.fullName,
    required this.isUpdate,
    required this.status,
    this.email,
    this.phone,
    this.appliedPosition,
    this.error,
  });

  final String id;

  /// Số dòng trong tệp, để HR mở tệp đối chiếu.
  final int rowNumber;
  final String fullName;
  final String? email;
  final String? phone;
  final String? appliedPosition;

  /// Trùng email hoặc số điện thoại với hồ sơ đã có thì là cập nhật.
  final bool isUpdate;

  /// `pending`, `accepted` hoặc `invalid`.
  final String status;
  final String? error;

  bool get pending => status == 'pending';
}

class CandidateImport {
  const CandidateImport({required this.id, required this.fileName, this.rows = const []});

  final String id;
  final String fileName;
  final List<ImportRow> rows;

  Iterable<ImportRow> get pendingRows => rows.where((r) => r.pending);
}
