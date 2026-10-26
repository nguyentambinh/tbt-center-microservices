/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:recruitment_service/src/positions.dart';
import 'package:tbt_common/tbt_common.dart';

/// Thứ tự các bước tuyển dụng; `rejected` có thể xảy ra ở bất kỳ bước nào
/// trước khi nhận việc.
const pipeline = [
  'submitted',
  'analyzed',
  'screening',
  'interview',
  'interviewed',
  'hired',
  'rejected',
];

/// Chỉ đổi qua /hire
const hireOnlyStatuses = {'hired'};

/// Bước chỉ đổi qua route riêng: hẹn phỏng vấn, nộp biên bản, nhận việc
const routedStatuses = {
  'interview': 'use_interview',
  'interviewed': 'use_minutes',
  'hired': 'use_hire',
};

/// Luồng chỉ đi tới: HR chỉ chuyển tay sang sàng lọc hoặc từ chối; từ
/// phỏng vấn trở đi không quay lại bước trước.
void checkMove(String from, String to) {
  if (routedStatuses[to] case final code?) {
    throw CandidateRuleViolation(code, 'Use the dedicated route for $to');
  }
  final allowed = switch (to) {
    'screening' => from == 'submitted' || from == 'analyzed',
    'rejected' => from != 'rejected' && from != 'hired',
    _ => false,
  };
  if (!allowed) {
    throw CandidateRuleViolation(
      'invalid_transition',
      'Cannot move from $from to $to',
    );
  }
}

/// Bước trước lần từ chối gần nhất (lịch sử cũ trước mới), để xem xét lại
String? statusBeforeRejection(List<String> history) {
  final last = history.lastIndexOf('rejected');
  for (var i = last - 1; i >= 0; i--) {
    if (history[i] != 'rejected') return history[i];
  }
  return null;
}

/// Vai trò xem danh sách ứng viên và chuyển bước tuyển dụng.
const recruiterRoles = {'hr', 'executive'};

/// Ứng viên tự sửa được hồ sơ khi chưa tới vòng phỏng vấn.
const editableStatuses = {'submitted', 'analyzed', 'screening'};

class CandidateRuleViolation implements Exception {
  const CandidateRuleViolation(this.code, this.message);

  final String code;
  final String message;
}

class CandidateProfileInput {
  const CandidateProfileInput({
    required this.fullName,
    this.email,
    this.phone,
    this.appliedPosition,
    this.consentAi = false,
    this.positionIds,
  });

  final String fullName;
  final String? email;
  final String? phone;
  final String? appliedPosition;
  final bool consentAi;

  /// Vị trí chọn từ danh sách HR mở; có thì thay [appliedPosition]
  final List<int>? positionIds;
}

abstract interface class CandidateRepository {
  Future<Map<String, dynamic>?> findBySubject(String subject);

  Future<Map<String, dynamic>?> findById(String id);

  /// Tạo hồ sơ lần đầu hoặc sửa hồ sơ của chính ứng viên.
  Future<Map<String, dynamic>> saveOwnProfile(
    String subject,
    String countryCode,
    CandidateProfileInput input,
  );

  Future<List<Map<String, dynamic>>> list({
    String? status,
    String? query,
    int? positionId,
  });

  /// Vị trí ứng viên đã chọn, gửi kèm CV cho AI so khớp
  Future<List<PositionBrief>> positionsFor(String candidateId);

  /// Gắn CV vừa tải lên vào hồ sơ của ứng viên. Hồ sơ quay về `submitted` để
  /// AI đọc lại CV mới. `null` nếu ứng viên chưa có hồ sơ.
  Future<Map<String, dynamic>?> attachCv(
    String subject, {
    required String objectKey,
    required String sha256,
  });

  /// Khóa object CV của ứng viên, `null` nếu chưa tải CV.
  Future<String?> cvKey(String candidateId);

  /// Lấy một hồ sơ chờ AI đọc: có CV, đồng ý cho AI, chưa có tóm tắt hoặc
  /// có vị trí mới chọn chưa so khớp.
  Future<({String id, String cvKey})?> nextForAnalysis({int maxAttempts = 3});

  Future<void> saveSummary(
    String candidateId,
    Map<String, dynamic> summary, {
    required String model,
  });

  Future<void> recordAiFailure(String candidateId, String error);

  /// HR chuyển bước; `null` nếu không có ứng viên. Ném
  /// [CandidateRuleViolation] khi sai luồng.
  Future<Map<String, dynamic>?> changeStatus(
    String id, {
    required String status,
    required String changedBy,
    String? note,
  });

  /// Đưa hồ sơ đã từ chối về bước trước đó; ném `not_rejected`
  Future<Map<String, dynamic>?> reconsider(
    String id, {
    required String changedBy,
    String? note,
  });

  /// null nếu hồ sơ do HR nhập
  Future<String?> subjectOf(String id);

  /// HR mở xem hồ sơ lần đầu: từ đó ứng viên không sửa hồ sơ, đổi CV được
  Future<void> markViewed(String id);

  /// Đổi sang hired, lưu phòng ban và lương đã thỏa thuận
  Future<Map<String, dynamic>?> markHired(
    String id, {
    required String employeeId,
    required String changedBy,
    String? subject,
    String? departmentId,
    double? salary,
    String? currency,
  });
}

class PostgresCandidateRepository implements CandidateRepository {
  PostgresCandidateRepository(this._db);

  final Database _db;

  static const _columns =
      'id::text, keycloak_sub, country_code, full_name, email, phone, '
      'applied_position, status, source, cv_object_key, consent_ai, '
      'employee_id, offer_department_id, offer_salary::text, offer_currency, '
      'viewed_at, created_at, updated_at';

  @override
  Future<Map<String, dynamic>?> findBySubject(String subject) =>
      _one('keycloak_sub = @key', subject);

  @override
  Future<Map<String, dynamic>?> findById(String id) =>
      _one('id::text = @key', id);

  Future<Map<String, dynamic>?> _one(String where, String key) async {
    final rows = await _db.query(
      'select $_columns from candidates where $where',
      params: {'key': key},
      fromPrimary: true,
    );
    if (rows.isEmpty) return null;
    final candidate = _json(rows.first);
    final history = await _db.query(
      'select status, note, changed_by, changed_at from '
      'candidate_status_history where candidate_id::text = @id '
      'order by changed_at',
      params: {'id': candidate['id']},
      fromPrimary: true,
    );
    final summary = await _db.query(
      'select summary from cv_summaries where candidate_id::text = @id',
      params: {'id': candidate['id']},
      fromPrimary: true,
    );
    return {
      ...candidate,
      'history': [
        for (final h in history)
          {
            'status': h['status'],
            'note': h['note'],
            'changedBy': h['changed_by'],
            'changedAt': (h['changed_at'] as DateTime).toIso8601String(),
          },
      ],
      'aiSummary': summary.isEmpty ? null : summary.first['summary'],
      'positions': await _positions(candidate['id'] as String),
      'interview': await _interview(candidate['id'] as String),
    };
  }

  Future<List<Map<String, dynamic>>> _positions(String id) async =>
      (await positionsOf(_db, [id]))[id] ?? const [];

  Future<Map<String, dynamic>?> _interview(String id) async {
    final rows = await _db.query(
      'select scheduled_at, location, note, state, proposed_by, '
      'minutes_name, minutes_uploaded_at from interviews '
      'where candidate_id::text = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    final events = await _db.query(
      'select action, scheduled_at, note, actor, at from interview_events '
      'where candidate_id::text = @id order by at, id',
      params: {'id': id},
      fromPrimary: true,
    );
    return {
      'scheduledAt': _utc(r['scheduled_at']),
      'location': r['location'],
      'note': r['note'],
      'state': r['state'],
      'proposedBy': r['proposed_by'],
      'minutesName': r['minutes_name'],
      'minutesUploadedAt': _utc(r['minutes_uploaded_at']),
      'events': [
        for (final e in events)
          {
            'action': e['action'],
            'scheduledAt': _utc(e['scheduled_at']),
            'note': e['note'],
            'actor': e['actor'],
            'at': _utc(e['at']),
          },
      ],
    };
  }

  String? _utc(Object? value) =>
      value is DateTime ? value.toUtc().toIso8601String() : null;

  @override
  Future<Map<String, dynamic>> saveOwnProfile(
    String subject,
    String countryCode,
    CandidateProfileInput input,
  ) {
    return _db.transaction((tx) async {
      final existing = await tx.execute(
        Sql.named(
          'select id::text, status, viewed_at from candidates '
          'where keycloak_sub = @sub for update',
        ),
        parameters: {'sub': subject},
      );
      final params = {
        'sub': subject,
        'country': countryCode,
        'name': input.fullName,
        'email': input.email,
        'phone': input.phone,
        'position': input.appliedPosition,
        'consent': input.consentAi,
      };

      if (existing.isEmpty) {
        final created = await tx.execute(
          Sql.named(
            'insert into candidates (keycloak_sub, country_code, full_name, '
            'email, phone, applied_position, consent_ai) values (@sub, '
            '@country, @name, @email, @phone, @position, @consent) '
            'returning $_columns',
          ),
          parameters: params,
        );
        final candidate = await _withPositions(
          tx,
          _json(created.first.toColumnMap()),
          input.positionIds,
        );
        await _history(tx, candidate['id'] as String, 'submitted', subject);
        await addOutboxEvent(
          tx,
          aggregate: 'candidate',
          aggregateId: candidate['id'] as String,
          eventType: 'CandidateApplied',
          payload: _eventPayload(candidate),
        );
        return candidate;
      }

      final current = existing.first.toColumnMap();
      if (!editableStatuses.contains(current['status']) ||
          current['viewed_at'] != null) {
        throw const CandidateRuleViolation(
          'profile_locked',
          'Profile can no longer be edited at this stage',
        );
      }
      final updated = await tx.execute(
        Sql.named(
          'update candidates set full_name = @name, email = @email, '
          'phone = @phone, applied_position = @position, '
          'consent_ai = @consent, updated_at = now() '
          'where keycloak_sub = @sub returning $_columns',
        ),
        parameters: params,
      );
      final candidate = await _withPositions(
        tx,
        _json(updated.first.toColumnMap()),
        input.positionIds,
      );
      await addOutboxEvent(
        tx,
        aggregate: 'candidate',
        aggregateId: candidate['id'] as String,
        eventType: 'CandidateProfileUpdated',
        payload: _eventPayload(candidate),
      );
      return candidate;
    });
  }

  /// Ghi vị trí đã chọn; đổi vị trí thì cho AI so khớp lại từ đầu
  Future<Map<String, dynamic>> _withPositions(
    TxSession tx,
    Map<String, dynamic> candidate,
    List<int>? positionIds,
  ) async {
    if (positionIds == null) return candidate;
    final id = candidate['id'] as String;
    final chosen = await replaceCandidatePositions(tx, id, positionIds);
    final updated = await tx.execute(
      Sql.named(
        'update candidates set applied_position = @titles, '
        'ai_attempts = case when @changed then 0 else ai_attempts end, '
        'ai_last_error = case when @changed then null else ai_last_error end '
        'where id = @id::uuid returning $_columns',
      ),
      parameters: {
        'titles': chosen.titles,
        'changed': chosen.changed,
        'id': id,
      },
    );
    return _json(updated.first.toColumnMap());
  }

  static const _byPosition =
      'id in (select candidate_id from candidate_positions '
      'where position_id = @position)';

  @override
  Future<List<PositionBrief>> positionsFor(String candidateId) =>
      positionBriefs(_db, candidateId);

  @override
  Future<List<Map<String, dynamic>>> list({
    String? status,
    String? query,
    int? positionId,
  }) async {
    final where = [
      if (status != null) 'status = @status',
      if (query != null && query.isNotEmpty)
        '(full_name ilike @q or email ilike @q)',
      if (positionId != null) _byPosition,
    ];
    final rows = await _db.query(
      'select $_columns from candidates '
      '${where.isEmpty ? '' : 'where ${where.join(' and ')}'} '
      'order by created_at desc limit 200',
      params: {
        'status': ?status,
        if (query != null && query.isNotEmpty) 'q': '%$query%',
        'position': ?positionId,
      },
    );
    final candidates = rows.map(_json).toList();
    final positions = await positionsOf(_db, [
      for (final c in candidates) c['id'] as String,
    ]);
    return [
      for (final c in candidates)
        {...c, 'positions': positions[c['id']] ?? const []},
    ];
  }

  @override
  Future<Map<String, dynamic>?> changeStatus(
    String id, {
    required String status,
    required String changedBy,
    String? note,
  }) {
    return _db.transaction((tx) async {
      final current = await tx.execute(
        Sql.named(
          'select status from candidates where id::text = @id for update',
        ),
        parameters: {'id': id},
      );
      if (current.isEmpty) return null;
      checkMove(current.first[0]! as String, status);
      if (status == 'rejected') {
        await tx.execute(
          Sql.named(
            "update interviews set state = 'cancelled', updated_at = now() "
            "where candidate_id::text = @id and state <> 'cancelled'",
          ),
          parameters: {'id': id},
        );
      }
      final updated = await tx.execute(
        Sql.named(
          'update candidates set status = @status, updated_at = now() '
          'where id::text = @id returning $_columns',
        ),
        parameters: {'status': status, 'id': id},
      );
      final candidate = _json(updated.first.toColumnMap());
      await _history(tx, id, status, changedBy, note: note);
      await addOutboxEvent(
        tx,
        aggregate: 'candidate',
        aggregateId: id,
        eventType: 'CandidateStatusChanged',
        payload: {..._eventPayload(candidate), 'note': note},
      );
      return candidate;
    });
  }

  @override
  Future<Map<String, dynamic>?> reconsider(
    String id, {
    required String changedBy,
    String? note,
  }) {
    return _db.transaction((tx) async {
      final current = await tx.execute(
        Sql.named(
          'select status from candidates where id::text = @id for update',
        ),
        parameters: {'id': id},
      );
      if (current.isEmpty) return null;
      if (current.first[0] != 'rejected') {
        throw const CandidateRuleViolation(
          'not_rejected',
          'Only rejected candidates can be reconsidered',
        );
      }
      final history = await tx.execute(
        Sql.named(
          'select status from candidate_status_history '
          'where candidate_id::text = @id order by changed_at, id',
        ),
        parameters: {'id': id},
      );
      final back =
          statusBeforeRejection([for (final h in history) h[0]! as String]) ??
          'screening';
      final updated = await tx.execute(
        Sql.named(
          'update candidates set status = @status, updated_at = now() '
          'where id::text = @id returning $_columns',
        ),
        parameters: {'status': back, 'id': id},
      );
      final candidate = _json(updated.first.toColumnMap());
      await _history(tx, id, back, changedBy, note: note ?? 'reconsidered');
      await addOutboxEvent(
        tx,
        aggregate: 'candidate',
        aggregateId: id,
        eventType: 'CandidateStatusChanged',
        payload: {..._eventPayload(candidate), 'note': 'reconsidered'},
      );
      return candidate;
    });
  }

  @override
  Future<void> markViewed(String id) => _db.execute(
    'update candidates set viewed_at = now() '
    'where id::text = @id and viewed_at is null',
    params: {'id': id},
  );

  @override
  Future<String?> subjectOf(String id) async {
    final rows = await _db.query(
      'select keycloak_sub from candidates where id::text = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    return rows.isEmpty ? null : rows.first['keycloak_sub'] as String?;
  }

  @override
  Future<Map<String, dynamic>?> markHired(
    String id, {
    required String employeeId,
    required String changedBy,
    String? subject,
    String? departmentId,
    double? salary,
    String? currency,
  }) {
    return _db.transaction((tx) async {
      final updated = await tx.execute(
        Sql.named(
          "update candidates set status = 'hired', employee_id = @employee, "
          'keycloak_sub = coalesce(keycloak_sub, @sub), '
          'offer_department_id = @dept, offer_salary = @salary, '
          'offer_currency = @currency, hired_position_id = (select '
          'position_id from candidate_positions where candidate_id = '
          'candidates.id order by match_score desc nulls last, position_id '
          'limit 1), updated_at = now() '
          "where id::text = @id and status <> 'hired' returning $_columns",
        ),
        parameters: {
          'employee': employeeId,
          'sub': subject,
          'id': id,
          'dept': departmentId,
          'salary': salary,
          'currency': currency,
        },
      );
      // Đã hired từ trước
      if (updated.isEmpty) return findById(id);
      final candidate = _json(updated.first.toColumnMap());
      await _history(tx, id, 'hired', changedBy);
      await addOutboxEvent(
        tx,
        aggregate: 'candidate',
        aggregateId: id,
        eventType: 'CandidateStatusChanged',
        payload: {..._eventPayload(candidate), 'employeeId': employeeId},
      );
      return candidate;
    });
  }

  @override
  Future<Map<String, dynamic>?> attachCv(
    String subject, {
    required String objectKey,
    required String sha256,
  }) {
    return _db.transaction((tx) async {
      final updated = await tx.execute(
        Sql.named(
          'update candidates set cv_object_key = @key, cv_sha256 = @sha, '
          "status = 'submitted', ai_attempts = 0, ai_last_error = null, "
          'updated_at = now() where keycloak_sub = @sub and viewed_at is null '
          'returning $_columns',
        ),
        parameters: {'key': objectKey, 'sha': sha256, 'sub': subject},
      );
      if (updated.isEmpty) return null;
      final candidate = _json(updated.first.toColumnMap());
      final id = candidate['id'] as String;
      await tx.execute(
        Sql.named('delete from cv_summaries where candidate_id::text = @id'),
        parameters: {'id': id},
      );
      await _history(tx, id, 'submitted', subject, note: 'cv_uploaded');
      await addOutboxEvent(
        tx,
        aggregate: 'candidate',
        aggregateId: id,
        eventType: 'CandidateCvUploaded',
        payload: _eventPayload(candidate),
      );
      return candidate;
    });
  }

  @override
  Future<String?> cvKey(String candidateId) async {
    final rows = await _db.query(
      'select cv_object_key from candidates where id::text = @id',
      params: {'id': candidateId},
    );
    return rows.isEmpty ? null : rows.first['cv_object_key'] as String?;
  }

  @override
  Future<({String id, String cvKey})?> nextForAnalysis({
    int maxAttempts = 3,
  }) async {
    final rows = await _db.query(
      'select c.id::text as id, c.cv_object_key from candidates c '
      'left join cv_summaries s on s.candidate_id = c.id '
      'where c.cv_object_key is not null and c.consent_ai and '
      'c.ai_attempts < @max and ( '
      "(c.status = 'submitted' and s.candidate_id is null) or "
      '(s.candidate_id is not null and exists (select 1 from '
      'candidate_positions cp where cp.candidate_id = c.id and '
      'cp.matched_at is null))) order by c.updated_at limit 1',
      params: {'max': maxAttempts},
      fromPrimary: true,
    );
    if (rows.isEmpty) return null;
    return (
      id: rows.first['id'] as String,
      cvKey: rows.first['cv_object_key'] as String,
    );
  }

  @override
  Future<void> saveSummary(
    String candidateId,
    Map<String, dynamic> summary, {
    required String model,
  }) {
    return _db.transaction((tx) async {
      await tx.execute(
        Sql.named(
          'insert into cv_summaries (candidate_id, summary, model) '
          'values (@id::uuid, @summary::jsonb, @model) '
          'on conflict (candidate_id) do update set '
          'summary = excluded.summary, model = excluded.model, '
          'created_at = now()',
        ),
        parameters: {
          'id': candidateId,
          'summary': jsonEncode(summary),
          'model': model,
        },
      );
      await saveMatches(tx, candidateId, summary['positionMatches']);
      final updated = await tx.execute(
        Sql.named(
          "update candidates set status = 'analyzed', updated_at = now() "
          "where id::text = @id and status = 'submitted' returning $_columns",
        ),
        parameters: {'id': candidateId},
      );
      if (updated.isEmpty) return;
      final candidate = _json(updated.first.toColumnMap());
      await _history(tx, candidateId, 'analyzed', 'ai:$model');
      await addOutboxEvent(
        tx,
        aggregate: 'candidate',
        aggregateId: candidateId,
        eventType: 'CandidateAnalyzed',
        payload: _eventPayload(candidate),
      );
    });
  }

  @override
  Future<void> recordAiFailure(String candidateId, String error) => _db.execute(
    'update candidates set ai_attempts = ai_attempts + 1, '
    'ai_last_error = @error where id::text = @id',
    params: {'id': candidateId, 'error': error},
  );

  Future<void> _history(
    TxSession tx,
    String id,
    String status,
    String by, {
    String? note,
  }) => tx.execute(
    Sql.named(
      'insert into candidate_status_history '
      '(candidate_id, status, note, changed_by) '
      'values (@id::uuid, @status, @note, @by)',
    ),
    parameters: {'id': id, 'status': status, 'note': note, 'by': by},
  );

  /// Sự kiện lên Hub chỉ mang thông tin cần cho báo cáo, không mang số
  /// điện thoại hay email (dữ liệu cá nhân ở lại khu vực).
  Map<String, Object?> _eventPayload(Map<String, dynamic> c) => {
    'candidateId': c['id'],
    'countryCode': c['countryCode'],
    'appliedPosition': c['appliedPosition'],
    'status': c['status'],
  };

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'countryCode': r['country_code'],
    'fullName': r['full_name'],
    'email': r['email'],
    'phone': r['phone'],
    'appliedPosition': r['applied_position'],
    'status': r['status'],
    'source': r['source'],
    'hasCv': r['cv_object_key'] != null,
    'employeeId': r['employee_id'],
    'offerDepartmentId': r['offer_department_id'],
    'offerSalary': r['offer_salary'],
    'offerCurrency': r['offer_currency'],
    'consentAi': r['consent_ai'],
    'viewedAt': (r['viewed_at'] as DateTime?)?.toUtc().toIso8601String(),
    'createdAt': (r['created_at'] as DateTime?)?.toIso8601String(),
    'updatedAt': (r['updated_at'] as DateTime?)?.toIso8601String(),
  };
}
