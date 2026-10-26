/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

/// Bên lập đề xuất dự án; Ban lãnh đạo (executive) duyệt
const proposerRoles = {'hr', 'finance', 'admin'};

/// Ngưỡng phân cấp (USD), cùng giá trị với service project_contract
const tierThresholdsUsd = [100000, 300000, 800000];
const tierMaxMonths = {1: 12, 2: 24, 3: 36, 4: 60};
const tierMinMembers = {1: 2, 2: 3, 3: 5, 4: 8};
const acceptanceGraceDays = 90;

int projectTier(double valueUsd) {
  for (var i = 0; i < tierThresholdsUsd.length; i++) {
    if (valueUsd < tierThresholdsUsd[i]) return i + 1;
  }
  return tierThresholdsUsd.length + 1;
}

/// Nội dung đề xuất dự án, hai bên sửa qua lại
class ProposalData {
  const ProposalData({
    this.name,
    this.customerName,
    this.customerType = 'company',
    this.customerContact,
    this.contractType,
    this.value,
    this.deposit,
    this.currency,
    this.startDate,
    this.endDate,
    this.acceptanceDate,
    this.memberIds = const [],
  });

  factory ProposalData.fromJson(Map<String, dynamic> j) {
    DateTime? day(String key) => DateTime.tryParse('${j[key]}');
    double? number(String key) => switch (j[key]) {
          final num n => n.toDouble(),
          final String s => double.tryParse(s),
          _ => null,
        };
    return ProposalData(
      name: j['name'] as String?,
      customerName: j['customerName'] as String?,
      customerType: j['customerType'] as String? ?? 'company',
      customerContact: j['customerContact'] as String?,
      contractType: j['contractType'] as String?,
      value: number('value'),
      deposit: number('deposit'),
      currency: j['currency'] as String?,
      startDate: day('startDate'),
      endDate: day('endDate'),
      acceptanceDate: day('acceptanceDate'),
      memberIds: [for (final id in j['memberIds'] as List? ?? const []) '$id'],
    );
  }

  final String? name;
  final String? customerName;
  final String customerType;
  final String? customerContact;
  final String? contractType;
  final double? value;
  final double? deposit;
  final String? currency;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? acceptanceDate;
  final List<String> memberIds;

  /// Ghép kết quả AI đọc hợp đồng vào ô còn trống, ô HR đã nhập giữ nguyên
  ProposalData fillFrom(ProposalData ai) => ProposalData(
        name: name ?? ai.name,
        customerName: customerName ?? ai.customerName,
        customerType: customerName == null ? ai.customerType : customerType,
        customerContact: customerContact ?? ai.customerContact,
        contractType: contractType ?? ai.contractType,
        value: value ?? ai.value,
        deposit: deposit ?? ai.deposit,
        currency: currency ?? ai.currency,
        startDate: startDate ?? ai.startDate,
        endDate: endDate ?? ai.endDate,
        acceptanceDate: acceptanceDate ?? ai.acceptanceDate,
        memberIds: memberIds,
      );

  ProposalData withMembers(List<String> ids) => ProposalData(
        name: name,
        customerName: customerName,
        customerType: customerType,
        customerContact: customerContact,
        contractType: contractType,
        value: value,
        deposit: deposit,
        currency: currency,
        startDate: startDate,
        endDate: endDate,
        acceptanceDate: acceptanceDate,
        memberIds: ids,
      );

  String? _day(DateTime? d) => d?.toIso8601String().substring(0, 10);

  Map<String, dynamic> toJson() => {
        'name': name,
        'customerName': customerName,
        'customerType': customerType,
        'customerContact': customerContact,
        'contractType': contractType,
        'value': value,
        'deposit': deposit,
        'currency': currency,
        'startDate': _day(startDate),
        'endDate': _day(endDate),
        'acceptanceDate': _day(acceptanceDate),
        'memberIds': memberIds,
      };

  /// Cùng luật với server, để báo lỗi ngay trên form trước khi gửi
  List<String> errors({required double rateToUsd, DateTime? today}) {
    final now = today ?? DateTime.now();
    final errors = <String>[
      if ((name ?? '').trim().isEmpty) 'name_required',
      if ((customerName ?? '').trim().isEmpty) 'customer_required',
      if (value == null || value! <= 0) 'invalid_value',
      if (deposit != null && (deposit! < 0 || (value != null && deposit! > value!))) 'invalid_deposit',
    ];
    final start = startDate;
    final end = endDate;
    if (start == null || end == null) return [...errors, 'dates_required'];
    if (start.isBefore(DateTime(now.year, now.month, now.day))) errors.add('start_in_past');
    if (!end.isAfter(start)) errors.add('end_before_start');
    final acceptance = acceptanceDate;
    if (acceptance != null && (acceptance.isBefore(end) || acceptance.difference(end).inDays > acceptanceGraceDays)) {
      errors.add('acceptance_out_of_range');
    }
    if (value != null && value! > 0) {
      final tier = projectTier(value! / rateToUsd);
      final months = (end.year - start.year) * 12 + end.month - start.month + (end.day > start.day ? 1 : 0);
      if (months > tierMaxMonths[tier]!) errors.add('too_long_for_tier');
      if (memberIds.length < tierMinMembers[tier]!) errors.add('too_few_members');
    }
    return errors;
  }
}

class ProposalEvent {
  const ProposalEvent({required this.action, required this.actor, required this.at, this.note});

  /// submitted, executive_counter, proposer_approve...
  final String action;
  final String actor;
  final DateTime at;
  final String? note;
}

class ProjectProposal {
  const ProjectProposal({
    required this.id,
    required this.status,
    required this.data,
    required this.version,
    required this.createdBy,
    required this.updatedAt,
    this.projectId,
    this.contractName,
    this.contractUrl,
    this.imageUrl,
    this.events = const [],
  });

  final int id;

  /// awaiting_executive, awaiting_proposer, approved, rejected
  final String status;
  final ProposalData data;
  final int version;
  final String createdBy;
  final DateTime updatedAt;
  final String? projectId;
  final String? contractName;
  final String? contractUrl;
  final String? imageUrl;
  final List<ProposalEvent> events;

  bool get open => status == 'awaiting_executive' || status == 'awaiting_proposer';
}

/// Nhân viên để chọn vào dự án, kèm số dự án đang làm
class StaffOption {
  const StaffOption({required this.id, required this.name, this.position, this.activeProjects = 0});

  final String id;
  final String name;
  final String? position;
  final int activeProjects;
}

class MemberSuggestion {
  const MemberSuggestion({required this.tier, required this.minMembers, required this.memberIds, required this.employees, this.reason, this.source = 'rules'});

  final int tier;
  final int minMembers;
  final List<String> memberIds;
  final List<StaffOption> employees;
  final String? reason;
  final String source;
}
