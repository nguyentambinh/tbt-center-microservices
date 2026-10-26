/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'job_position.dart';

/// Các bước tuyển dụng, cùng thứ tự với service recruitment.
const candidateStages = ['submitted', 'analyzed', 'screening', 'interview', 'interviewed', 'hired', 'rejected'];

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

/// Lịch phỏng vấn: hai bên đề xuất giờ qua lại tới khi xác nhận
class Interview {
  const Interview({required this.scheduledAt, required this.state, required this.proposedBy, this.location, this.note, this.minutesName});

  final DateTime scheduledAt;

  /// awaiting_candidate, awaiting_hr, confirmed, cancelled
  final String state;
  final String proposedBy;
  final String? location;
  final String? note;
  final String? minutesName;

  bool get confirmed => state == 'confirmed';
  bool get cancelled => state == 'cancelled';

  /// Đã qua giờ hẹn thì HR mới tải biên bản được
  bool get held => !scheduledAt.isAfter(DateTime.now());
}

/// Gợi ý thỏa thuận lúc nhận việc (AI hoặc theo người cùng chức vụ)
class OfferSuggestion {
  const OfferSuggestion({required this.departments, this.departmentId, this.baseSalary, this.currency, this.reason, this.source = 'rules'});

  final List<({String id, String name, String? company})> departments;
  final String? departmentId;
  final double? baseSalary;
  final String? currency;
  final String? reason;
  final String source;

  bool get fromAi => source != 'rules';
}

/// Thỏa thuận HR chốt trong hộp nhận việc
class HireOffer {
  const HireOffer({this.departmentId, this.baseSalary, this.currency});

  final String? departmentId;
  final double? baseSalary;
  final String? currency;
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
    this.interview,
    this.positions = const [],
    this.viewedAt,
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
  final Interview? interview;

  /// Vị trí đã chọn, điểm phù hợp cao trước
  final List<PositionMatch> positions;

  /// HR đã mở xem hồ sơ: từ đó ứng viên không sửa được nữa
  final DateTime? viewedAt;

  bool get editable => editableStages.contains(status) && viewedAt == null;

  /// Điểm cao nhất AI chấm trong các vị trí đã chọn
  int? get bestScore => positions.map((p) => p.score).nonNulls.fold<int?>(null, (m, s) => m == null || s > m ? s : m);
}

/// Kết quả nhận vào làm
class HireResult {
  const HireResult({required this.employeeId, required this.login, this.temporaryPassword, this.salarySet = true});

  final String employeeId;
  final String login;
  final String? temporaryPassword;

  /// payroll lỗi lúc nhận việc thì HR nhập lương lại sau
  final bool salarySet;
}

class CandidateInput {
  const CandidateInput({required this.fullName, this.email, this.phone, this.appliedPosition, this.consentAi = false, this.positionIds});

  final String fullName;
  final String? email;
  final String? phone;
  final String? appliedPosition;
  final bool consentAi;

  /// Vị trí tick chọn từ danh sách HR mở; `null` khi khu vực chưa mở vị trí nào
  final List<int>? positionIds;
}
