/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'package:postgres/postgres.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// Số vị trí tối đa một ứng viên chọn cùng lúc
const maxPositionsPerCandidate = 5;

/// Vị trí gửi kèm CV cho AI so khớp
class PositionBrief {
  const PositionBrief({
    required this.id,
    required this.title,
    this.department,
    this.description = '',
    this.requirements = '',
  });

  final int id;
  final String title;
  final String? department;
  final String description;
  final String requirements;
}

class PositionInput {
  const PositionInput({
    required this.title,
    required this.headcount,
    this.department,
    this.description = '',
    this.requirements = '',
    this.status = 'open',
  });

  final String title;
  final int headcount;
  final String? department;
  final String description;
  final String requirements;
  final String status;
}

/// Tên 1–120 ký tự, cần 1–500 người, không ít hơn số đã tuyển
void checkPositionInput(PositionInput input, {int hired = 0}) {
  final title = input.title.trim();
  if (title.isEmpty || title.length > 120) {
    throw const CandidateRuleViolation('invalid_title', 'Title 1-120 chars');
  }
  if (input.headcount < 1 || input.headcount > 500) {
    throw const CandidateRuleViolation(
      'invalid_headcount',
      'Headcount must be 1-500',
    );
  }
  if (input.headcount < hired) {
    throw const CandidateRuleViolation(
      'headcount_below_hired',
      'Headcount is lower than people already hired',
    );
  }
  if (!{'open', 'closed'}.contains(input.status)) {
    throw const CandidateRuleViolation('invalid_status', 'open or closed');
  }
}

/// Ứng viên chọn 1–5 vị trí; vị trí mới chọn phải đang mở và còn chỗ.
/// Vị trí đã chọn từ trước được giữ dù sau đó đã đủ người
void checkSelection(
  List<int> ids,
  Map<int, ({String status, int remaining})> found, {
  Set<int> current = const {},
}) {
  if (ids.isEmpty) {
    throw const CandidateRuleViolation(
      'no_position',
      'Choose at least one position',
    );
  }
  if (ids.toSet().length > maxPositionsPerCandidate) {
    throw const CandidateRuleViolation(
      'too_many_positions',
      'Choose at most 5 positions',
    );
  }
  for (final id in ids) {
    final p = found[id];
    if (p == null) {
      throw CandidateRuleViolation('position_not_found', 'No position $id');
    }
    if (!current.contains(id) && (p.status != 'open' || p.remaining <= 0)) {
      throw CandidateRuleViolation(
        'position_unavailable',
        'Position $id is closed or full',
      );
    }
  }
}

/// Kết quả so khớp của AI: chỉ giữ vị trí ứng viên đã chọn, điểm 0–100
List<({int id, int score, String verdict, String strengths, String gaps})>
normalizeMatches(Object? raw, Set<int> ids) {
  final seen = <int>{};
  return [
    for (final m in raw is List ? raw : const [])
      if (m is Map)
        if (int.tryParse('${m['positionId']}') case final id?)
          if (ids.contains(id) && seen.add(id))
            (
              id: id,
              score: ((m['score'] as num?)?.round() ?? 0).clamp(0, 100),
              verdict: '${m['verdict'] ?? ''}',
              strengths: '${m['strengths'] ?? ''}',
              gaps: '${m['gaps'] ?? ''}',
            ),
  ];
}

abstract interface class PositionRepository {
  Future<List<Map<String, dynamic>>> list({bool openOnly = false});

  /// Vị trí kèm danh sách ứng viên, điểm phù hợp cao trước
  Future<Map<String, dynamic>?> find(int id);

  Future<Map<String, dynamic>> create(
    PositionInput input, {
    required String by,
  });

  /// Ném `headcount_below_hired`, `title_exists`
  Future<Map<String, dynamic>?> update(int id, PositionInput input);
}

class PostgresPositionRepository implements PositionRepository {
  PostgresPositionRepository(this._db);

  final Database _db;

  static const _select =
      'select p.id, p.title, p.department, p.description, p.requirements, '
      'p.headcount, p.status, p.created_by, p.created_at, p.updated_at, '
      '(select count(*)::int from candidate_positions cp '
      'where cp.position_id = p.id) as applicants, '
      '(select count(*)::int from candidates c where c.hired_position_id = '
      "p.id and c.status = 'hired') as hired from job_positions p";

  @override
  Future<List<Map<String, dynamic>>> list({bool openOnly = false}) async {
    final rows = await _db.query(
      '$_select ${openOnly ? "where p.status = 'open'" : ''} '
      "order by p.status = 'open' desc, p.created_at desc",
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        if (!openOnly || _json(r)['remaining'] as int > 0) _json(r),
    ];
  }

  @override
  Future<Map<String, dynamic>?> find(int id) async {
    final rows = await _db.query(
      '$_select where p.id = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    if (rows.isEmpty) return null;
    final applicants = await _db.query(
      'select c.id::text as id, c.full_name, c.status, cp.match_score, '
      'cp.match_verdict, cp.matched_at from candidate_positions cp '
      'join candidates c on c.id = cp.candidate_id where cp.position_id = @id '
      'order by cp.match_score desc nulls last, c.created_at',
      params: {'id': id},
      fromPrimary: true,
    );
    return {
      ..._json(rows.first),
      'candidates': [
        for (final a in applicants)
          {
            'id': a['id'],
            'fullName': a['full_name'],
            'status': a['status'],
            'matchScore': a['match_score'],
            'matchVerdict': a['match_verdict'],
            'matched': a['matched_at'] != null,
          },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> create(
    PositionInput input, {
    required String by,
  }) async {
    checkPositionInput(input);
    try {
      final rows = await _db.execute(
        'insert into job_positions (title, department, description, '
        'requirements, headcount, status, created_by) values (@title, '
        '@department, @description, @requirements, @headcount, @status, @by) '
        'returning id',
        params: {..._params(input), 'by': by},
      );
      return (await find(rows.first['id'] as int))!;
    } on ServerException catch (e) {
      if (e.code == '23505') throw _titleExists;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> update(int id, PositionInput input) async {
    final current = await find(id);
    if (current == null) return null;
    checkPositionInput(input, hired: current['hired'] as int);
    try {
      await _db.execute(
        'update job_positions set title = @title, department = @department, '
        'description = @description, requirements = @requirements, '
        'headcount = @headcount, status = @status, updated_at = now() '
        'where id = @id',
        params: {..._params(input), 'id': id},
      );
    } on ServerException catch (e) {
      if (e.code == '23505') throw _titleExists;
      rethrow;
    }
    return find(id);
  }

  static const _titleExists = CandidateRuleViolation(
    'title_exists',
    'An open position with this title already exists',
  );

  Map<String, Object?> _params(PositionInput input) => {
    'title': input.title.trim(),
    'department': (input.department?.trim().isEmpty ?? true)
        ? null
        : input.department!.trim(),
    'description': input.description.trim(),
    'requirements': input.requirements.trim(),
    'headcount': input.headcount,
    'status': input.status,
  };

  Map<String, dynamic> _json(Map<String, dynamic> r) {
    final hired = r['hired'] as int? ?? 0;
    return {
      'id': r['id'],
      'title': r['title'],
      'department': r['department'],
      'description': r['description'],
      'requirements': r['requirements'],
      'headcount': r['headcount'],
      'status': r['status'],
      'applicants': r['applicants'] ?? 0,
      'hired': hired,
      'remaining': (r['headcount'] as int) - hired,
      'createdBy': r['created_by'],
      'createdAt': (r['created_at'] as DateTime).toUtc().toIso8601String(),
    };
  }
}

/// Thay danh sách vị trí của ứng viên trong cùng giao dịch lưu hồ sơ.
/// Trả tên các vị trí (ghi vào `applied_position`) và có đổi gì không
Future<({String titles, bool changed})> replaceCandidatePositions(
  TxSession tx,
  String candidateId,
  List<int> ids,
) async {
  final unique = ids.toSet().toList();
  final current = {
    for (final r in await tx.execute(
      Sql.named(
        'select position_id from candidate_positions '
        'where candidate_id = @id::uuid',
      ),
      parameters: {'id': candidateId},
    ))
      r[0]! as int,
  };
  final rows = await tx.execute(
    Sql.named(
      'select p.id, p.title, p.status, p.headcount - (select count(*)::int '
      'from candidates c where c.hired_position_id = p.id and '
      "c.status = 'hired') from job_positions p where p.id = any(@ids)",
    ),
    parameters: {'ids': TypedValue(Type.bigIntegerArray, unique)},
  );
  checkSelection(unique, {
    for (final r in rows)
      r[0]! as int: (status: r[2]! as String, remaining: r[3]! as int),
  }, current: current);
  final titles = {for (final r in rows) r[0]! as int: r[1]! as String};
  await tx.execute(
    Sql.named(
      'delete from candidate_positions where candidate_id = @id::uuid '
      'and not (position_id = any(@ids))',
    ),
    parameters: {
      'id': candidateId,
      'ids': TypedValue(Type.bigIntegerArray, unique),
    },
  );
  for (final p in unique.where((p) => !current.contains(p))) {
    await tx.execute(
      Sql.named(
        'insert into candidate_positions (candidate_id, position_id) '
        'values (@id::uuid, @position)',
      ),
      parameters: {'id': candidateId, 'position': p},
    );
  }
  return (
    titles: [for (final id in unique) titles[id]!].join(', '),
    changed: current.length != unique.length || !current.containsAll(unique),
  );
}

/// Vị trí ứng viên đã chọn, để gửi AI so khớp
Future<List<PositionBrief>> positionBriefs(
  Database db,
  String candidateId,
) async {
  final rows = await db.query(
    'select p.id, p.title, p.department, p.description, p.requirements '
    'from candidate_positions cp join job_positions p on p.id = cp.position_id '
    'where cp.candidate_id::text = @id order by p.id',
    params: {'id': candidateId},
    fromPrimary: true,
  );
  return [
    for (final r in rows)
      PositionBrief(
        id: r['id'] as int,
        title: r['title'] as String,
        department: r['department'] as String?,
        description: r['description'] as String? ?? '',
        requirements: r['requirements'] as String? ?? '',
      ),
  ];
}

/// Lưu điểm phù hợp; vị trí AI bỏ sót vẫn đánh dấu đã chấm để không gọi lại
Future<void> saveMatches(
  TxSession tx,
  String candidateId,
  Object? raw,
) async {
  final ids = {
    for (final r in await tx.execute(
      Sql.named(
        'select position_id from candidate_positions '
        'where candidate_id = @id::uuid',
      ),
      parameters: {'id': candidateId},
    ))
      r[0]! as int,
  };
  final matches = {for (final m in normalizeMatches(raw, ids)) m.id: m};
  for (final id in ids) {
    final m = matches[id];
    await tx.execute(
      Sql.named(
        'update candidate_positions set match_score = @score, '
        'match_verdict = @verdict, match_strengths = @strengths, '
        'match_gaps = @gaps, matched_at = now() '
        'where candidate_id = @id::uuid and position_id = @position',
      ),
      parameters: {
        'id': candidateId,
        'position': id,
        'score': m?.score,
        'verdict': m?.verdict,
        'strengths': m?.strengths,
        'gaps': m?.gaps,
      },
    );
  }
}

/// Vị trí đã chọn của nhiều ứng viên, kèm điểm phù hợp
Future<Map<String, List<Map<String, dynamic>>>> positionsOf(
  Database db,
  List<String> candidateIds,
) async {
  if (candidateIds.isEmpty) return const {};
  final rows = await db.query(
    'select cp.candidate_id::text as candidate_id, p.id, p.title, p.status, '
    'cp.match_score, cp.match_verdict, cp.match_strengths, cp.match_gaps, '
    'cp.matched_at from candidate_positions cp join job_positions p '
    'on p.id = cp.position_id where cp.candidate_id::text = any(@ids) '
    'order by cp.match_score desc nulls last, p.id',
    params: {'ids': TypedValue(Type.textArray, candidateIds)},
    fromPrimary: true,
  );
  final result = <String, List<Map<String, dynamic>>>{};
  for (final r in rows) {
    (result[r['candidate_id'] as String] ??= []).add({
      'id': r['id'],
      'title': r['title'],
      'status': r['status'],
      'matchScore': r['match_score'],
      'matchVerdict': r['match_verdict'],
      'matchStrengths': r['match_strengths'],
      'matchGaps': r['match_gaps'],
      'matched': r['matched_at'] != null,
    });
  }
  return result;
}
