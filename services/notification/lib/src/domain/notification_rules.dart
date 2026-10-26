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
    this.aggregateId,
  });

  factory HubEvent.fromJson(Map<String, dynamic> json) => HubEvent(
    id: json['id'] as int,
    eventId: json['eventId'] as String?,
    eventType: json['eventType'] as String,
    payload: json['payload'] as Map<String, dynamic>,
    occurredAt: DateTime.tryParse(json['occurredAt'] as String? ?? ''),
    aggregateId: json['aggregateId'] as String?,
  );

  final int id;

  /// Mã đối tượng của sự kiện (đơn nghỉ, ứng viên...), app mở thẳng tới đó
  final String? aggregateId;

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
List<NewNotification> notificationsFor(HubEvent e) => [
  ..._businessNotifications(e),
  if (adminLogEvents.contains(e.eventType))
    (
      recipient: roleRecipient('admin'),
      kind: 'audit_log',
      params: {
        'event': e.eventType,
        'by':
            e.payload['by'] ?? e.payload['changedBy'] ?? e.payload['createdBy'],
        'ref': ?e.aggregateId,
      },
    ),
];

/// Sự kiện báo cho quản trị dưới dạng nhật ký mới: thao tác quản trị, đổi cấu
/// hình và việc văn phòng quản lý làm thẳng. Quản trị không nhận việc cần duyệt
const adminLogEvents = {
  'AdminSqlWrite',
  'AdminSqlRead',
  'BackupCreated',
  'AccountChanged',
  'PositionCreated',
  'PositionUpdated',
  'PositionDeleted',
  'HolidayAdded',
  'HolidayRemoved',
  'ShiftChanged',
  'EmployeePromoted',
  'PositionChanged',
  'SalaryChanged',
  'BonusGranted',
  'PenaltyApplied',
};

List<NewNotification> _businessNotifications(HubEvent e) {
  final p = e.payload;
  NewNotification to(String recipient, String kind, Map<String, Object?> v) =>
      (recipient: recipient, kind: kind, params: {...v, 'ref': ?e.aggregateId});

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
    case 'ProfileChangeRequested':
      return [
        to(roleRecipient('hr'), 'profile_change_requested', {
          'employeeId': p['employeeId'],
        }),
      ];
    case 'ProfileChangeApproved' || 'ProfileChangeRejected':
      final employee = p['employeeId'] as String?;
      if (employee == null) return const [];
      return [
        to(
          employeeRecipient(employee),
          e.eventType == 'ProfileChangeApproved'
              ? 'profile_change_approved'
              : 'profile_change_rejected',
          {'note': p['note']},
        ),
      ];
    case 'PromotionNominated':
      return [
        to(roleRecipient('executive'), 'promotion_nominated', {
          'employeeId': p['employeeId'],
          'proposedPosition': p['proposedPosition'],
        }),
      ];
    case 'PromotionApproved' || 'PromotionRejected':
      final employee = p['employeeId'] as String?;
      if (employee == null) return const [];
      final approved = e.eventType == 'PromotionApproved';
      return [
        to(
          employeeRecipient(employee),
          approved ? 'promotion_approved' : 'promotion_rejected',
          {'proposedPosition': p['proposedPosition'], 'note': p['note']},
        ),
        to(
          roleRecipient('hr'),
          approved ? 'promotion_approved_hr' : 'promotion_rejected_hr',
          {'employeeId': employee, 'proposedPosition': p['proposedPosition']},
        ),
      ];
    case 'EmployeeTransferred' || 'DepartmentHeadChanged':
      final employee = p['employeeId'] as String?;
      if (employee == null) return const [];
      return [
        to(
          employeeRecipient(employee),
          e.eventType == 'EmployeeTransferred'
              ? 'employee_transferred'
              : 'department_head_assigned',
          {'departmentId': p['toDepartment'] ?? p['departmentId']},
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
    case 'InterviewScheduled' || 'InterviewConfirmed':
      final candidate = p['candidateId'] as String?;
      if (candidate == null) return const [];
      final params = {
        'scheduledAt': p['scheduledAt'],
        'countryCode': p['countryCode'],
        'appliedPosition': p['appliedPosition'],
      };
      return [
        to(
          candidateRecipient(candidate),
          e.eventType == 'InterviewScheduled'
              ? 'interview_scheduled'
              : 'interview_confirmed',
          params,
        ),
        if (e.eventType == 'InterviewConfirmed')
          to(roleRecipient('hr'), 'interview_confirmed_hr', params),
      ];
    case 'InterviewProposed':
      return [
        to(roleRecipient('hr'), 'interview_proposed', {
          'scheduledAt': p['scheduledAt'],
          'countryCode': p['countryCode'],
          'appliedPosition': p['appliedPosition'],
        }),
      ];
    case 'ProjectProposed':
      return [
        to(roleRecipient('executive'), 'project_proposed', {
          'name': p['name'],
          'proposalId': p['proposalId'],
        }),
      ];
    case 'ProjectProposalCountered':
      return [
        for (final role in ['hr', 'finance'])
          to(roleRecipient(role), 'project_countered', {
            'name': p['name'],
            'proposalId': p['proposalId'],
          }),
      ];
    case 'ProjectProposalApproved' || 'ProjectProposalRejected':
      final kind = e.eventType == 'ProjectProposalApproved'
          ? 'project_approved'
          : 'project_rejected';
      return [
        for (final role in ['hr', 'finance'])
          to(roleRecipient(role), kind, {
            'name': p['name'],
            'projectId': p['projectId'],
          }),
      ];
    case 'RaiseRequested':
      return [
        to(roleRecipient('hr'), 'raise_requested', {
          'employeeId': p['employeeId'],
        }),
      ];
    case 'RaiseForwarded':
      return [
        to(roleRecipient('executive'), 'raise_forwarded', {
          'employeeId': p['employeeId'],
        }),
      ];
    case 'RaiseApproved' || 'RaiseRejected' || 'RaiseReturned':
      final employee = p['employeeId'] as String?;
      if (employee == null) return const [];
      return [
        to(employeeRecipient(employee), switch (e.eventType) {
          'RaiseApproved' => 'raise_approved',
          'RaiseRejected' => 'raise_rejected',
          _ => 'raise_returned',
        }, const {}),
      ];
    case 'ReportSubmitted':
      return [
        to(roleRecipient('executive'), 'report_submitted', {
          'reportKind': p['kind'],
          'period': p['period'],
        }),
      ];
    case 'ReportAcknowledged' || 'ReportReturned':
      final kind = p['kind'] as String?;
      if (kind == null) return const [];
      return [
        to(
          roleRecipient(kind),
          e.eventType == 'ReportAcknowledged'
              ? 'report_acknowledged'
              : 'report_returned',
          {'reportKind': kind, 'period': p['period']},
        ),
      ];
    case 'ResignationRequested' || 'ResignationWithdrawn':
      return [
        to(
          roleRecipient('hr'),
          e.eventType == 'ResignationRequested'
              ? 'resignation_requested'
              : 'resignation_withdrawn',
          {'employeeId': p['employeeId'], 'lastDay': p['lastDay']},
        ),
      ];
    case 'ResignationApproved' || 'ResignationRejected':
      final employee = p['employeeId'] as String?;
      if (employee == null) return const [];
      return [
        to(
          employeeRecipient(employee),
          e.eventType == 'ResignationApproved'
              ? 'resignation_approved'
              : 'resignation_rejected',
          {'lastDay': p['lastDay']},
        ),
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
    // Văn phòng quản lý làm thẳng: báo cho chính nhân viên bị ảnh hưởng
    case 'EmployeePromoted' || 'PositionChanged':
      return [
        to(employeeRecipient(p['employeeId'] as String), 'position_changed', {
          'position': p['position'],
        }),
      ];
    case 'SalaryChanged':
      return [
        to(employeeRecipient(p['employeeId'] as String), 'salary_changed', {
          'amount': p['baseSalary'],
          'currency': p['currency'],
        }),
      ];
    case 'BonusGranted' || 'PenaltyApplied':
      return [
        to(
          employeeRecipient(p['employeeId'] as String),
          e.eventType == 'BonusGranted' ? 'bonus_granted' : 'penalty_applied',
          {
            'amount': p['amount'],
            'currency': p['currency'],
            'reason': p['reason'],
          },
        ),
      ];
    default:
      return const [];
  }
}
