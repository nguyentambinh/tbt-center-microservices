/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'package:postgres/postgres.dart';
import 'package:recruitment_service/src/candidate_repository.dart';
import 'package:tbt_common/tbt_common.dart';

/// Bên tham gia hẹn phỏng vấn
enum Party { hr, candidate }

/// Trạng thái kế tiếp của lịch phỏng vấn khi [party] làm [action].
/// HR: đặt giờ (đặt lại được khi quá giờ) hoặc từ chối ứng viên.
/// Ứng viên: chỉ xác nhận giờ HR hẹn.
String nextInterviewState(String state, Party party, String action) {
  // Hai bên đã chốt giờ thì không bên nào đổi giờ nữa
  if (state == 'confirmed' && action == 'propose') {
    throw const CandidateRuleViolation(
      'interview_locked',
      'Interview time is confirmed by both sides',
    );
  }
  final next = switch ((party, action)) {
    (Party.hr, 'propose') when state != 'cancelled' => 'awaiting_candidate',
    (Party.hr, 'decline') when state != 'cancelled' => 'cancelled',
    (Party.candidate, 'confirm') when state == 'awaiting_candidate' =>
      'confirmed',
    _ => null,
  };
  if (next == null) {
    throw CandidateRuleViolation(
      'invalid_interview_action',
      'Cannot $action while interview is $state',
    );
  }
  return next;
}

/// Giờ phỏng vấn phải sau thời điểm hiện tại
void checkFutureTime(DateTime at, DateTime now) {
  if (!at.isAfter(now)) {
    throw const CandidateRuleViolation(
      'time_in_past',
      'Interview time must be in the future',
    );
  }
}

/// Biên bản phỏng vấn nhận Word, Excel
const minutesExtensions = {'doc', 'docx', 'xls', 'xlsx'};

abstract interface class InterviewRepository {
  /// HR hẹn lần đầu: hồ sơ phải ở bước sàng lọc (hoặc đang phỏng vấn mà lịch
  /// cũ đã hủy); hồ sơ chuyển sang `interview`
  Future<Map<String, dynamic>?> schedule(
    String candidateId, {
    required DateTime at,
    required String by,
    String? location,
    String? note,
  });

  Future<Map<String, dynamic>?> respond(
    String candidateId, {
    required Party party,
    required String action,
    required String by,
    DateTime? at,
    String? note,
  });

  /// Lưu biên bản sau buổi phỏng vấn đã xác nhận; hồ sơ sang `interviewed`
  Future<Map<String, dynamic>?> attachMinutes(
    String candidateId, {
    required String objectKey,
    required String fileName,
    required String by,
  });

  Future<({String key, String name})?> minutes(String candidateId);
}

class PostgresInterviewRepository implements InterviewRepository {
  PostgresInterviewRepository(
    this._db,
    this._candidates, {
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final Database _db;
  final CandidateRepository _candidates;
  final DateTime Function() _now;

  @override
  Future<Map<String, dynamic>?> schedule(
    String candidateId, {
    required DateTime at,
    required String by,
    String? location,
    String? note,
  }) async {
    checkFutureTime(at, _now());
    final done = await _db.transaction((tx) async {
      final c = await _lockCandidate(tx, candidateId);
      if (c == null) return false;
      final existing = await _lockInterview(tx, candidateId);
      final status = c['status'] as String;
      final reopen = status == 'interview' && existing?['state'] == 'cancelled';
      if (status != 'screening' && !reopen) {
        throw CandidateRuleViolation(
          existing == null ? 'not_screened' : 'interview_exists',
          'Interview can be scheduled only after screening',
        );
      }
      await tx.execute(
        Sql.named(
          'insert into interviews (candidate_id, scheduled_at, location, '
          'note, state, proposed_by) values (@id::uuid, @at, @location, '
          "@note, 'awaiting_candidate', 'hr') "
          'on conflict (candidate_id) do update set '
          'scheduled_at = excluded.scheduled_at, location = excluded.location, '
          "note = excluded.note, state = 'awaiting_candidate', "
          "proposed_by = 'hr', minutes_key = null, minutes_name = null, "
          'minutes_uploaded_at = null, updated_at = now()',
        ),
        parameters: {
          'id': candidateId,
          'at': at.toUtc(),
          'location': location,
          'note': note,
        },
      );
      await _event(tx, candidateId, 'scheduled', by, at: at, note: note);
      if (status != 'interview') {
        await tx.execute(
          Sql.named(
            "update candidates set status = 'interview', updated_at = now() "
            'where id::text = @id',
          ),
          parameters: {'id': candidateId},
        );
        await _history(tx, candidateId, 'interview', by);
        await _statusEvent(tx, c, 'interview');
      }
      await _notify(tx, c, 'InterviewScheduled', at: at, location: location);
      await _mail(tx, c, 'scheduled', at: at, location: location, note: note);
      return true;
    });
    return done ? _candidates.findById(candidateId) : null;
  }

  @override
  Future<Map<String, dynamic>?> respond(
    String candidateId, {
    required Party party,
    required String action,
    required String by,
    DateTime? at,
    String? note,
  }) async {
    if (action == 'propose') {
      if (at == null) {
        throw const CandidateRuleViolation('time_required', 'Propose a time');
      }
      checkFutureTime(at, _now());
    }
    final done = await _db.transaction((tx) async {
      final c = await _lockCandidate(tx, candidateId);
      if (c == null) return false;
      final interview = await _lockInterview(tx, candidateId);
      if (interview == null || c['status'] != 'interview') {
        throw const CandidateRuleViolation(
          'no_interview',
          'No interview to respond to',
        );
      }
      final scheduled = interview['scheduled_at'] as DateTime;
      final next = nextInterviewState(
        interview['state'] as String,
        party,
        action,
      );
      // Đã tới giờ hẹn thì không xác nhận nữa, phải hẹn giờ mới
      if (action == 'confirm' && !scheduled.isAfter(_now())) {
        throw const CandidateRuleViolation(
          'time_in_past',
          'The proposed time has passed, propose a new one',
        );
      }
      await tx.execute(
        Sql.named(
          'update interviews set state = @state, '
          'scheduled_at = coalesce(@at, scheduled_at), '
          'proposed_by = case when @at::timestamptz is null then proposed_by '
          'else @party end, updated_at = now() where candidate_id::text = @id',
        ),
        parameters: {
          'id': candidateId,
          'state': next,
          'at': at?.toUtc(),
          'party': party.name,
        },
      );
      final when = at ?? scheduled;
      await _event(
        tx,
        candidateId,
        '${party.name}_$action',
        by,
        at: at,
        note: note,
      );
      final location = interview['location'] as String?;
      switch ((party, action)) {
        case (Party.hr, 'decline'):
          await tx.execute(
            Sql.named(
              "update candidates set status = 'rejected', updated_at = now() "
              'where id::text = @id',
            ),
            parameters: {'id': candidateId},
          );
          await _history(tx, candidateId, 'rejected', by, note: note);
          await _statusEvent(tx, c, 'rejected');
          await _mail(
            tx,
            c,
            'declined',
            at: when,
            location: location,
            note: note,
          );
        case (_, 'confirm'):
          await _notify(
            tx,
            c,
            'InterviewConfirmed',
            at: when,
            location: location,
          );
          await _mail(
            tx,
            c,
            'confirmed',
            at: when,
            location: location,
            note: note,
          );
        case (Party.hr, _):
          await _notify(
            tx,
            c,
            'InterviewScheduled',
            at: when,
            location: location,
          );
          await _mail(
            tx,
            c,
            'scheduled',
            at: when,
            location: location,
            note: note,
          );
        case (Party.candidate, _):
          await _notify(
            tx,
            c,
            'InterviewProposed',
            at: when,
            location: location,
          );
      }
      return true;
    });
    return done ? _candidates.findById(candidateId) : null;
  }

  @override
  Future<Map<String, dynamic>?> attachMinutes(
    String candidateId, {
    required String objectKey,
    required String fileName,
    required String by,
  }) async {
    final done = await _db.transaction((tx) async {
      final c = await _lockCandidate(tx, candidateId);
      if (c == null) return false;
      final interview = await _lockInterview(tx, candidateId);
      if (c['status'] != 'interview' || interview?['state'] != 'confirmed') {
        throw const CandidateRuleViolation(
          'interview_not_confirmed',
          'Minutes need a confirmed interview',
        );
      }
      if ((interview!['scheduled_at'] as DateTime).isAfter(_now())) {
        throw const CandidateRuleViolation(
          'interview_not_held',
          'Upload the minutes after the interview time',
        );
      }
      await tx.execute(
        Sql.named(
          'update interviews set minutes_key = @key, minutes_name = @name, '
          'minutes_uploaded_at = now(), updated_at = now() '
          'where candidate_id::text = @id',
        ),
        parameters: {'id': candidateId, 'key': objectKey, 'name': fileName},
      );
      await tx.execute(
        Sql.named(
          "update candidates set status = 'interviewed', updated_at = now() "
          'where id::text = @id',
        ),
        parameters: {'id': candidateId},
      );
      await _event(tx, candidateId, 'minutes_uploaded', by, note: fileName);
      await _history(tx, candidateId, 'interviewed', by);
      await _statusEvent(tx, c, 'interviewed');
      return true;
    });
    return done ? _candidates.findById(candidateId) : null;
  }

  @override
  Future<({String key, String name})?> minutes(String candidateId) async {
    final rows = await _db.query(
      'select minutes_key, minutes_name from interviews '
      'where candidate_id::text = @id and minutes_key is not null',
      params: {'id': candidateId},
    );
    if (rows.isEmpty) return null;
    return (
      key: rows.first['minutes_key'] as String,
      name: rows.first['minutes_name'] as String? ?? 'minutes',
    );
  }

  Future<Map<String, dynamic>?> _lockCandidate(TxSession tx, String id) async {
    final rows = await tx.execute(
      Sql.named(
        'select id::text, status, full_name, email, country_code, '
        'applied_position from candidates where id::text = @id for update',
      ),
      parameters: {'id': id},
    );
    return rows.isEmpty ? null : rows.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> _lockInterview(TxSession tx, String id) async {
    final rows = await tx.execute(
      Sql.named(
        'select state, scheduled_at, location from interviews '
        'where candidate_id::text = @id for update',
      ),
      parameters: {'id': id},
    );
    return rows.isEmpty ? null : rows.first.toColumnMap();
  }

  Future<void> _event(
    TxSession tx,
    String id,
    String action,
    String actor, {
    DateTime? at,
    String? note,
  }) => tx.execute(
    Sql.named(
      'insert into interview_events (candidate_id, action, scheduled_at, '
      'note, actor) values (@id::uuid, @action, @at, @note, @actor)',
    ),
    parameters: {
      'id': id,
      'action': action,
      'at': at?.toUtc(),
      'note': note,
      'actor': actor,
    },
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

  Future<void> _statusEvent(
    TxSession tx,
    Map<String, dynamic> c,
    String status,
  ) => addOutboxEvent(
    tx,
    aggregate: 'candidate',
    aggregateId: c['id'] as String,
    eventType: 'CandidateStatusChanged',
    payload: {
      'candidateId': c['id'],
      'countryCode': c['country_code'],
      'appliedPosition': c['applied_position'],
      'status': status,
    },
  );

  /// Sự kiện lên Hub không mang tên, email ứng viên
  Future<void> _notify(
    TxSession tx,
    Map<String, dynamic> c,
    String type, {
    required DateTime at,
    String? location,
  }) => addOutboxEvent(
    tx,
    aggregate: 'candidate',
    aggregateId: c['id'] as String,
    eventType: type,
    payload: {
      'candidateId': c['id'],
      'countryCode': c['country_code'],
      'appliedPosition': c['applied_position'],
      'scheduledAt': at.toUtc().toIso8601String(),
      'location': location,
    },
  );

  Future<void> _mail(
    TxSession tx,
    Map<String, dynamic> c,
    String kind, {
    required DateTime at,
    String? location,
    String? note,
  }) async {
    final email = (c['email'] as String?)?.trim() ?? '';
    if (email.isEmpty) return;
    final message = interviewEmail(
      kind,
      country: c['country_code'] as String? ?? '',
      name: c['full_name'] as String? ?? '',
      position: c['applied_position'] as String?,
      at: at,
      location: location,
      note: note,
    );
    await tx.execute(
      Sql.named(
        'insert into email_queue (recipient, subject, body) '
        'values (@to, @subject, @body)',
      ),
      parameters: {
        'to': email,
        'subject': message.subject,
        'body': message.body,
      },
    );
  }
}

/// Nội dung email phỏng vấn theo ngôn ngữ của nước ứng tuyển
({String subject, String body}) interviewEmail(
  String kind, {
  required String country,
  required String name,
  required DateTime at,
  String? position,
  String? location,
  String? note,
}) {
  final time = formatRegionTime(at, country);
  final role = position ?? '';
  final lang = switch (country) {
    'VN' => 'vi',
    'DE' => 'de',
    'BR' => 'pt',
    _ => 'en',
  };
  final text = switch ((lang, kind)) {
    ('vi', 'scheduled') => (
      'TBT Center: lịch phỏng vấn $role',
      'Chào $name,\n\nTBT Center mời bạn phỏng vấn vị trí $role lúc $time.',
    ),
    ('vi', 'confirmed') => (
      'TBT Center: đã xác nhận lịch phỏng vấn',
      'Chào $name,\n\nLịch phỏng vấn vị trí $role lúc $time đã được xác nhận.',
    ),
    ('vi', _) => (
      'TBT Center: kết quả hồ sơ $role',
      'Chào $name,\n\nRất tiếc, TBT Center chưa thể tiếp tục với hồ sơ của '
          'bạn cho vị trí $role.',
    ),
    ('de', 'scheduled') => (
      'TBT Center: Vorstellungsgespräch $role',
      'Hallo $name,\n\nTBT Center lädt Sie am $time zum Gespräch für die '
          'Stelle $role ein.',
    ),
    ('de', 'confirmed') => (
      'TBT Center: Termin bestätigt',
      'Hallo $name,\n\nIhr Gesprächstermin für $role am $time ist bestätigt.',
    ),
    ('de', _) => (
      'TBT Center: Ihre Bewerbung $role',
      'Hallo $name,\n\nLeider können wir Ihre Bewerbung für $role nicht '
          'weiterverfolgen.',
    ),
    ('pt', 'scheduled') => (
      'TBT Center: entrevista $role',
      'Olá $name,\n\nA TBT Center convida você para a entrevista da vaga '
          '$role em $time.',
    ),
    ('pt', 'confirmed') => (
      'TBT Center: entrevista confirmada',
      'Olá $name,\n\nSua entrevista para $role em $time está confirmada.',
    ),
    ('pt', _) => (
      'TBT Center: sua candidatura $role',
      'Olá $name,\n\nInfelizmente não seguiremos com sua candidatura para '
          '$role.',
    ),
    (_, 'scheduled') => (
      'TBT Center: interview for $role',
      'Hello $name,\n\nTBT Center invites you to an interview for $role on '
          '$time.',
    ),
    (_, 'confirmed') => (
      'TBT Center: interview confirmed',
      'Hello $name,\n\nYour interview for $role on $time is confirmed.',
    ),
    (_, _) => (
      'TBT Center: your application for $role',
      'Hello $name,\n\nUnfortunately we will not continue with your '
          'application for $role.',
    ),
  };
  final hint = switch (lang) {
    'vi' => 'Mở ứng dụng TBT Center để xác nhận hoặc đề xuất giờ khác.',
    'de' =>
      'Öffnen Sie die TBT Center App, um zu bestätigen oder einen '
          'anderen Termin vorzuschlagen.',
    'pt' => 'Abra o app TBT Center para confirmar ou sugerir outro horário.',
    _ => 'Open the TBT Center app to confirm or suggest another time.',
  };
  final lines = [
    text.$2,
    if (kind != 'declined' && (location ?? '').isNotEmpty) location!,
    if ((note ?? '').isNotEmpty) note!,
    if (kind == 'scheduled') hint,
    'TBT Center',
  ];
  return (subject: text.$1, body: lines.join('\n\n'));
}
