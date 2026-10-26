/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:io';

import 'package:tbt_common/tbt_common.dart';

/// Tổng giờ làm (giờ thường + tăng ca) của từng nhân viên, đọc từ attendance
typedef HoursLookup =
    Future<Map<String, ({double work, double overtime, int days})>> Function({
      required DateTime from,
      required DateTime to,
    });

/// Hỏi attendance qua `/internal/hours?from=&to=`
HoursLookup attendanceHours(InternalClient attendance) =>
    ({required from, required to}) async {
      String day(DateTime d) => d.toIso8601String().substring(0, 10);
      final data = await attendance.get(
        '/internal/hours',
        query: {'from': day(from), 'to': day(to)},
      );
      return {
        for (final r in (data['items'] as List).cast<Map<String, dynamic>>())
          r['employeeId'] as String: (
            work: (r['workHours'] as num? ?? 0).toDouble(),
            overtime: (r['overtimeHours'] as num? ?? 0).toDouble(),
            days: (r['days'] as num? ?? 0).toInt(),
          ),
      };
    };

/// Trưởng phòng đứng đầu, còn lại theo tổng giờ làm tại công ty giảm dần
List<Map<String, dynamic>> orderMembers(
  List<Map<String, dynamic>> members, {
  required String? headId,
  required Map<String, ({double work, double overtime, int days})> hours,
}) {
  double total(Map<String, dynamic> m) {
    final h = hours[m['id']];
    return h == null ? 0 : h.work + h.overtime;
  }

  return [
    for (final m in members)
      {...m, 'totalHours': total(m), 'isHead': m['id'] == headId},
  ]..sort((a, b) {
    if (a['isHead'] == true) return -1;
    if (b['isHead'] == true) return 1;
    return (b['totalHours'] as double).compareTo(a['totalHours'] as double);
  });
}

/// Điểm xếp hạng: giờ thường + 1,5 × tăng ca + 2 × số ngày đi làm
List<Map<String, dynamic>> rankEmployees(
  List<Map<String, dynamic>> employees,
  Map<String, ({double work, double overtime, int days})> hours, {
  int limit = 20,
}) {
  final scored = [
    for (final e in employees)
      if (hours[e['id']] case final h?)
        {
          ...e,
          'workHours': h.work,
          'overtimeHours': h.overtime,
          'days': h.days,
          'score': double.parse(
            (h.work + 1.5 * h.overtime + 2 * h.days).toStringAsFixed(1),
          ),
        },
  ]..sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
  return [
    for (final (i, e) in scored.take(limit).indexed) {...e, 'rank': i + 1},
  ];
}

/// Gợi ý xếp phòng ban cho người chưa có phòng: AI nếu có,
/// không thì theo chức vụ trùng nhiều nhất
class DepartmentAdvisor {
  DepartmentAdvisor(this._ai);

  factory DepartmentAdvisor.fromEnvironment() =>
      DepartmentAdvisor(StructuredAi.fromEnvironment(Platform.environment));

  final StructuredAi _ai;

  static const _schema = {
    'type': 'object',
    'properties': {
      'assignments': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'employeeId': {'type': 'string'},
            'departmentId': {'type': 'string'},
            'reason': {'type': 'string'},
          },
          'required': ['employeeId', 'departmentId', 'reason'],
        },
      },
      'newDepartments': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'reason': {'type': 'string'},
            'employeeIds': {
              'type': 'array',
              'items': {'type': 'string'},
            },
          },
          'required': ['name', 'reason', 'employeeIds'],
        },
      },
    },
    'required': ['assignments', 'newDepartments'],
  };

  /// [departments]: id, name, positions (chức vụ của thành viên);
  /// [people]: id, name, position. Kết quả chỉ chứa mã có thật.
  Future<Map<String, dynamic>> suggest(
    List<Map<String, dynamic>> departments,
    List<Map<String, dynamic>> people, {
    String language = 'vi',
  }) async {
    if (people.isEmpty) {
      return {
        'assignments': <Object>[],
        'newDepartments': <Object>[],
        'source': 'none',
      };
    }
    final result = await _ai.generate(
      system:
          'Bạn là chuyên viên nhân sự của một tập đoàn xây dựng. Xếp từng '
          'nhân viên chưa có phòng ban vào phòng ban phù hợp nhất dựa trên '
          'chức vụ và chức vụ của thành viên hiện có. Nếu nhiều người không '
          'hợp phòng nào, đề xuất tạo phòng ban mới. Lý do viết ngắn bằng '
          'ngôn ngữ $language.',
      user: _prompt(departments, people),
      schema: _schema,
    );
    final ids = {for (final p in people) p['id']};
    final deptIds = {for (final d in departments) d['id']};
    if (result != null) {
      final assignments = [
        for (final a
            in (result['assignments'] as List? ?? const [])
                .cast<Map<String, dynamic>>())
          if (ids.contains(a['employeeId']) &&
              deptIds.contains(a['departmentId']))
            a,
      ];
      final newDepartments = [
        for (final n
            in (result['newDepartments'] as List? ?? const [])
                .cast<Map<String, dynamic>>())
          {
            ...n,
            'employeeIds': [
              for (final e in n['employeeIds'] as List? ?? const [])
                if (ids.contains(e)) e,
            ],
          },
      ];
      return {
        'assignments': assignments,
        'newDepartments': newDepartments,
        'source': _ai.lastProvider ?? 'ai',
      };
    }
    return {...heuristic(departments, people), 'source': 'rules'};
  }

  static String _prompt(
    List<Map<String, dynamic>> departments,
    List<Map<String, dynamic>> people,
  ) {
    final lines = ['Phòng ban hiện có:'];
    for (final d in departments) {
      final positions = (d['positions'] as List).join(', ');
      lines.add('- ${d['id']}: ${d['name']} (chức vụ thành viên: $positions)');
    }
    lines.add('Nhân viên chưa có phòng ban:');
    for (final p in people) {
      final position = p['position'] ?? 'chưa rõ';
      lines.add('- ${p['id']}: ${p['name']}, chức vụ $position');
    }
    return lines.join('\n');
  }

  /// Phòng có nhiều thành viên cùng chức vụ nhất; không có thì gom người
  /// cùng chức vụ thành phòng mới
  static Map<String, dynamic> heuristic(
    List<Map<String, dynamic>> departments,
    List<Map<String, dynamic>> people,
  ) {
    final assignments = <Map<String, dynamic>>[];
    final orphans = <String, List<String>>{};
    for (final p in people) {
      final position = (p['position'] as String? ?? '').toLowerCase();
      Map<String, dynamic>? best;
      var bestCount = 0;
      for (final d in departments) {
        final count = (d['positions'] as List)
            .where((x) => '$x'.toLowerCase() == position)
            .length;
        if (count > bestCount) {
          best = d;
          bestCount = count;
        }
      }
      if (best != null && position.isNotEmpty) {
        assignments.add({
          'employeeId': p['id'],
          'departmentId': best['id'],
          'reason':
              '$bestCount người trong phòng có cùng chức vụ ${p['position']}',
        });
      } else {
        (orphans[p['position'] as String? ?? '-'] ??= []).add(
          p['id'] as String,
        );
      }
    }
    return {
      'assignments': assignments,
      'newDepartments': [
        for (final MapEntry(:key, :value) in orphans.entries)
          {
            'name': 'Phòng $key',
            'reason':
                '${value.length} người chức vụ $key chưa có phòng phù hợp',
            'employeeIds': value,
          },
      ],
    };
  }
}

/// Dự án nhân viên đang tham gia (project_contract)
typedef ProjectsOf = Future<List<Map<String, dynamic>>> Function(
  String employeeId,
);

/// Rút nhân viên khỏi mọi dự án, trả số dòng đã rút (project_contract)
typedef RemoveFromProjects = Future<int> Function(String employeeId);

/// Tăng lương cơ bản theo phần trăm (payroll)
typedef RaiseSalary = Future<void> Function(
  String employeeId,
  double percent,
  String reason,
);

ProjectsOf projectsOf(InternalClient projects) =>
    (id) async =>
        ((await projects.get(
                  '/internal/members/${Uri.encodeComponent(id)}',
                ))['items']
                as List)
            .cast<Map<String, dynamic>>();

RemoveFromProjects removeFromProjects(InternalClient projects) =>
    (id) async =>
        (await projects.delete(
              '/internal/members/${Uri.encodeComponent(id)}',
              const <String, Object>{},
            ))['removed']
            as int? ??
        0;

RaiseSalary raiseSalary(InternalClient payroll) => (id, percent, reason) async {
  await payroll.post('/internal/salaries/${Uri.encodeComponent(id)}/raise', {
    'percent': percent,
    'reason': reason,
  });
};
