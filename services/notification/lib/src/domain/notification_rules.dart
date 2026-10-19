/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

/// Một sự kiện đọc từ sổ audit ở Hub.
class HubEvent {
  const HubEvent({
    required this.id,
    required this.eventId,
    required this.eventType,
    required this.payload,
    this.occurredAt,
  });

  factory HubEvent.fromJson(Map<String, dynamic> json) => HubEvent(
    id: json['id'] as int,
    eventId: json['eventId'] as String?,
    eventType: json['eventType'] as String,
    payload: json['payload'] as Map<String, dynamic>,
    occurredAt: DateTime.tryParse(json['occurredAt'] as String? ?? ''),
  );

  final int id;

  /// Sự kiện ghi trước khi outbox có `event_id` thì không có mã này.
  final String? eventId;
  final String eventType;
  final Map<String, dynamic> payload;

  /// Lúc sự việc xảy ra ở khu vực, dùng làm giờ của thông báo.
  final DateTime? occurredAt;
}

/// Thông báo sắp ghi: gửi cho ai, loại gì, tham số để app tự ghép câu.
typedef NewNotification = ({
  String recipient,
  String kind,
  Map<String, Object?> params,
});

String employeeRecipient(String id) => 'employee:$id';
String candidateRecipient(String id) => 'candidate:$id';
String roleRecipient(String role) => 'role:$role';

/// Sự kiện nào báo cho ai (R18, R97). Hàm thuần để dễ test; sự kiện không
/// liên quan tới người dùng thì trả danh sách rỗng.
List<NewNotification> notificationsFor(HubEvent e) {
  final p = e.payload;
  NewNotification to(String recipient, String kind, Map<String, Object?> v) =>
      (recipient: recipient, kind: kind, params: v);

  switch (e.eventType) {
    case 'LeaveRequested':
      return [
        to(roleRecipient('hr'), 'leave_requested', {
          'employeeId': p['employeeId'],
          'fromDate': p['fromDate'],
          'days': p['days'],
        }),
      ];
    case 'LeaveApproved' || 'LeaveRejected':
      final employee = p['employeeId'] as String?;
      if (employee == null) return const [];
      return [
        to(
          employeeRecipient(employee),
          e.eventType == 'LeaveApproved' ? 'leave_approved' : 'leave_rejected',
          {'fromDate': p['fromDate'], 'days': p['days']},
        ),
      ];
    case 'OvertimeRequested':
      return [
        to(roleRecipient('hr'), 'overtime_requested', {
          'employeeId': p['employeeId'],
          'workDate': p['workDate'],
          'hours': p['hours'],
        }),
      ];
    case 'OvertimeApproved' || 'OvertimeRejected':
      final employee = p['employeeId'] as String?;
      if (employee == null) return const [];
      return [
        to(
          employeeRecipient(employee),
          e.eventType == 'OvertimeApproved'
              ? 'overtime_approved'
              : 'overtime_rejected',
          {'workDate': p['workDate'], 'hours': p['hours']},
        ),
      ];
    case 'CandidateApplied':
      return [
        to(roleRecipient('hr'), 'candidate_applied', {
          'appliedPosition': p['appliedPosition'],
        }),
      ];
    case 'CandidateStatusChanged':
      final candidate = p['candidateId'] as String?;
      if (candidate == null) return const [];
      return [
        to(candidateRecipient(candidate), 'candidate_status', {
          'status': p['status'],
          'appliedPosition': p['appliedPosition'],
        }),
      ];
    case 'PayrollRunCompleted':
      return [
        to(roleRecipient('finance'), 'payroll_paid', {'period': p['period']}),
      ];
    // Mỗi nhân viên nhận phiếu lương riêng (bước sau pivot của Saga)
    case 'PayslipIssued':
      final employee = p['employeeId'] as String?;
      if (employee == null) return const [];
      return [
        to(employeeRecipient(employee), 'payslip_issued', {
          'period': p['period'],
        }),
      ];
    case 'PayrollRunNeedsAttention':
      return [
        to(roleRecipient('finance'), 'payroll_needs_attention', {
          'period': p['period'],
        }),
      ];
    case 'PayrollRunFailed':
      return [
        to(roleRecipient('finance'), 'payroll_failed', {'period': p['period']}),
      ];
    case 'ProjectAccepted':
      return [
        to(roleRecipient('finance'), 'project_accepted', {
          'projectId': p['projectId'],
          'acceptedOn': p['acceptedOn'],
        }),
      ];
    case 'FinancePeriodClosed':
      return [
        to(roleRecipient('executive'), 'finance_closed', {
          'period': p['period'],
        }),
      ];
    default:
      return const [];
  }
}
