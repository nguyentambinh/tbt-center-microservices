/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

/// Đề xuất sửa thông tin cá nhân: nhân viên gửi, HR duyệt thì mới ghi vào hồ sơ
class ChangeRequest {
  const ChangeRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.changes,
    required this.status,
    required this.requestedAt,
    this.reason,
    this.note,
  });

  factory ChangeRequest.fromJson(Map<String, dynamic> json) => ChangeRequest(
        id: json['id'] as int,
        employeeId: json['employeeId'] as String,
        employeeName: json['employeeName'] as String? ?? json['employeeId'] as String,
        changes: (json['changes'] as Map?)?.cast<String, Object?>() ?? const {},
        status: json['status'] as String,
        requestedAt: DateTime.parse(json['requestedAt'] as String).toLocal(),
        reason: json['reason'] as String?,
        note: json['note'] as String?,
      );

  final int id;
  final String employeeId;
  final String employeeName;

  /// Tên trường trong API (phone, address, heightCm...) → giá trị mới
  final Map<String, Object?> changes;

  /// `pending`, `approved`, `rejected`
  final String status;
  final DateTime requestedAt;
  final String? reason;
  final String? note;

  bool get pending => status == 'pending';
}

/// Trường nhân viên được đề xuất sửa, khớp với service hr
const editableProfileFields = [
  'email',
  'phone',
  'address',
  'facebook',
  'xHandle',
  'hometownCode',
  'heightCm',
  'weightKg',
  'visionScore',
  'medicalHistory',
];

const numericProfileFields = {'heightCm', 'weightKg', 'visionScore'};
