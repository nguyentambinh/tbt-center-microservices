/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Phát triển ứng dụng đa nền tảng
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

/// Lý do giải thể phòng ban, khớp với service hr
const dissolutionReasons = ['no_longer_needed', 'restructured', 'underperforming', 'outsourced', 'business_closed'];

class Department {
  const Department({required this.id, required this.name, this.companyId, this.company, this.headId, this.headName, this.members = 0});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        companyId: json['companyId'] as String?,
        company: json['company'] as String?,
        headId: json['headId'] as String?,
        headName: json['headName'] as String?,
        members: json['members'] as int? ?? 0,
      );

  final String id;
  final String name;
  final String? companyId;
  final String? company;
  final String? headId;
  final String? headName;
  final int members;
}

class OrgPerson {
  const OrgPerson({
    required this.id,
    required this.name,
    this.photoUrl,
    this.position,
    this.department,
    this.departmentId,
    this.isHead = false,
    this.totalHours = 0,
    this.workHours = 0,
    this.overtimeHours = 0,
    this.days = 0,
    this.score = 0,
    this.rank = 0,
  });

  factory OrgPerson.fromJson(Map<String, dynamic> json) => OrgPerson(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
        position: json['position'] as String?,
        department: json['department'] as String?,
        departmentId: json['departmentId'] as String?,
        isHead: json['isHead'] == true,
        totalHours: (json['totalHours'] as num? ?? 0).toDouble(),
        workHours: (json['workHours'] as num? ?? 0).toDouble(),
        overtimeHours: (json['overtimeHours'] as num? ?? 0).toDouble(),
        days: json['days'] as int? ?? 0,
        score: (json['score'] as num? ?? 0).toDouble(),
        rank: json['rank'] as int? ?? 0,
      );

  final String id;
  final String name;
  final String? photoUrl;
  final String? position;
  final String? department;
  final String? departmentId;
  final bool isHead;
  final double totalHours;
  final double workHours;
  final double overtimeHours;
  final int days;
  final double score;
  final int rank;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.length == 1 ? parts.first[0] : '${parts.last[0]}${parts.first[0]}';
  }
}

class DepartmentDetail {
  const DepartmentDetail({required this.department, required this.members});

  factory DepartmentDetail.fromJson(Map<String, dynamic> json) => DepartmentDetail(
        department: Department.fromJson(json),
        members: [for (final m in json['memberList'] as List? ?? const []) OrgPerson.fromJson(m as Map<String, dynamic>)],
      );

  final Department department;
  final List<OrgPerson> members;
}

/// Gợi ý của AI (hoặc luật dự phòng): xếp vào phòng có sẵn, hoặc lập phòng mới
class PlacementSuggestion {
  const PlacementSuggestion({required this.assignments, required this.newDepartments, required this.source});

  factory PlacementSuggestion.fromJson(Map<String, dynamic> json) => PlacementSuggestion(
        assignments: [
          for (final a in json['assignments'] as List? ?? const [])
            (
              employeeId: (a as Map<String, dynamic>)['employeeId'] as String,
              departmentId: a['departmentId'] as String,
              reason: a['reason'] as String? ?? '',
            ),
        ],
        newDepartments: [
          for (final n in json['newDepartments'] as List? ?? const [])
            (
              name: (n as Map<String, dynamic>)['name'] as String? ?? '',
              reason: n['reason'] as String? ?? '',
              employeeIds: [for (final e in n['employeeIds'] as List? ?? const []) e as String],
            ),
        ],
        source: json['source'] as String? ?? 'rules',
      );

  final List<({String employeeId, String departmentId, String reason})> assignments;
  final List<({String name, String reason, List<String> employeeIds})> newDepartments;

  /// claude, gemini hoặc rules
  final String source;

  bool get byAi => source == 'claude' || source == 'gemini' || source == 'ai';
}

class Nomination {
  const Nomination({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.proposedPosition,
    required this.raisePercent,
    required this.reason,
    required this.status,
    this.photoUrl,
    this.currentPosition,
    this.createdAt,
    this.note,
    this.groupRole,
  });

  factory Nomination.fromJson(Map<String, dynamic> json) => Nomination(
        id: json['id'] as int,
        employeeId: json['employeeId'] as String,
        employeeName: json['employeeName'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
        currentPosition: json['currentPosition'] as String?,
        proposedPosition: json['proposedPosition'] as String? ?? '',
        raisePercent: (json['raisePercent'] as num? ?? 0).toDouble(),
        reason: json['reason'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        note: json['note'] as String?,
        groupRole: json['scope'] == 'group' ? json['groupRole'] as String? ?? 'hr' : null,
      );

  final int id;
  final String employeeId;
  final String employeeName;
  final String? photoUrl;
  final String? currentPosition;
  final String proposedPosition;
  final double raisePercent;
  final String reason;
  final String status;
  final DateTime? createdAt;
  final String? note;

  /// Đề cử lên cấp tập đoàn (hr, finance); chỉ văn phòng tập đoàn duyệt
  final String? groupRole;

  bool get pending => status == 'pending';
  bool get toGroup => groupRole != null;
}

/// Giá trị cho bộ lọc hồ sơ
class EmployeeFilters {
  const EmployeeFilters({this.departments = const [], this.positions = const [], this.companies = const []});

  factory EmployeeFilters.fromJson(Map<String, dynamic> json) {
    List<({String id, String name})> list(String key) => [
          for (final r in json[key] as List? ?? const [])
            (id: (r as Map<String, dynamic>)['id'] as String, name: r['name'] as String? ?? ''),
        ];
    return EmployeeFilters(departments: list('departments'), positions: list('positions'), companies: list('companies'));
  }

  final List<({String id, String name})> departments;
  final List<({String id, String name})> positions;
  final List<({String id, String name})> companies;
}

/// Một người trên cây tổ chức: cấp chức vụ 1 (nhân viên) tới 6 (Ban lãnh đạo)
class TreePerson {
  const TreePerson({required this.id, required this.name, required this.level, this.position, this.photoUrl, this.isHead = false, this.departmentId, this.departmentName});

  factory TreePerson.fromJson(Map<String, dynamic> json, {String? departmentId, String? departmentName}) => TreePerson(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        level: (json['level'] as num?)?.toInt() ?? 1,
        position: json['position'] as String?,
        photoUrl: json['photoUrl'] as String?,
        isHead: json['isHead'] == true,
        departmentId: departmentId,
        departmentName: departmentName,
      );

  final String id;
  final String name;
  final int level;
  final String? position;
  final String? photoUrl;
  final bool isHead;
  final String? departmentId;
  final String? departmentName;

  /// Trưởng phòng đứng trên cả phòng: tính tối thiểu cấp 4
  int get rank => isHead && level < 4 ? 4 : level;
}

/// Một phòng ban trên cây: người xếp từ cấp cao xuống, trưởng phòng đầu tiên
class TreeDepartment {
  const TreeDepartment({required this.id, required this.name, required this.people, this.company});

  final String id;
  final String name;
  final String? company;
  final List<TreePerson> people;

  TreePerson? get head => people.where((p) => p.isHead).firstOrNull;
}

class OrgTree {
  const OrgTree({required this.departments, this.unassigned = const []});

  factory OrgTree.fromJson(Map<String, dynamic> json) => OrgTree(
        departments: [
          for (final d in json['departments'] as List? ?? const [])
            TreeDepartment(
              id: (d as Map<String, dynamic>)['id'] as String,
              name: d['name'] as String? ?? '',
              company: d['company'] as String?,
              people: [
                for (final p in d['people'] as List? ?? const [])
                  TreePerson.fromJson(p as Map<String, dynamic>, departmentId: d['id'] as String, departmentName: d['name'] as String?),
              ]..sort((a, b) => b.rank.compareTo(a.rank)),
            ),
        ],
        unassigned: [for (final p in json['unassigned'] as List? ?? const []) TreePerson.fromJson(p as Map<String, dynamic>)],
      );

  final List<TreeDepartment> departments;
  final List<TreePerson> unassigned;
}
