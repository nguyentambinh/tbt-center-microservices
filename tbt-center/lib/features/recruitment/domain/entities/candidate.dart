/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Các bước tuyển dụng, cùng thứ tự với service recruitment.
const candidateStages = ['submitted', 'analyzed', 'screening', 'interview', 'offered', 'hired', 'rejected'];

/// Chỉ đổi bằng nút Nhận vào làm
const hireOnlyStages = {'hired'};

/// Ứng viên tự sửa được hồ sơ khi chưa tới vòng phỏng vấn.
const editableStages = {'submitted', 'analyzed', 'screening'};

class StageChange {
  const StageChange({required this.status, required this.changedAt, this.note, this.changedBy});

  final String status;
  final DateTime changedAt;
  final String? note;
  final String? changedBy;
}

class Candidate {
  const Candidate({
    required this.id,
    required this.fullName,
    required this.status,
    this.email,
    this.phone,
    this.appliedPosition,
    this.consentAi = false,
    this.hasCv = false,
    this.history = const [],
    this.aiSummary,
  });

  final String id;
  final String fullName;
  final String status;
  final String? email;
  final String? phone;
  final String? appliedPosition;
  final bool consentAi;
  final bool hasCv;
  final List<StageChange> history;
  final Map<String, dynamic>? aiSummary;

  bool get editable => editableStages.contains(status);
}

/// Kết quả nhận vào làm
class HireResult {
  const HireResult({required this.employeeId, required this.login, this.temporaryPassword});

  final String employeeId;
  final String login;
  final String? temporaryPassword;
}

class CandidateInput {
  const CandidateInput({required this.fullName, this.email, this.phone, this.appliedPosition, this.consentAi = false});

  final String fullName;
  final String? email;
  final String? phone;
  final String? appliedPosition;
  final bool consentAi;
}
