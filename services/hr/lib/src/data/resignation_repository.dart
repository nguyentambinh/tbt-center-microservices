/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Thời gian báo trước tối thiểu khi xin thôi việc
const minNoticeDays = 30;

class ResignationViolation implements Exception {
  const ResignationViolation(this.code, this.message);

  final String code;
  final String message;
}

/// Ngày làm cuối phải cách hôm nay ít nhất [minNoticeDays] ngày
void checkNotice(DateTime lastDay, DateTime today) {
  final start = DateTime(today.year, today.month, today.day);
  if (lastDay.difference(start).inDays < minNoticeDays) {
    throw const ResignationViolation(
      'notice_too_short',
      'Give at least 30 days of notice',
    );
  }
}

/// Trạng thái kế tiếp: HR duyệt/từ chối đơn chờ; nhân viên rút đơn chờ;
/// HR hoàn tất đơn đã duyệt khi đã qua ngày làm cuối
String nextResignationStatus(
  String status,
  String action, {
  required bool hr,
  required bool lastDayPassed,
}) {
  final next = switch ((status, action, hr)) {
    ('pending', 'approve', true) => 'approved',
    ('pending', 'reject', true) => 'rejected',
    ('pending', 'withdraw', false) => 'withdrawn',
    ('approved', 'complete', true) when lastDayPassed => 'completed',
    _ => null,
  };
  if (next == null) {
    throw ResignationViolation(
      action == 'complete' && status == 'approved'
          ? 'before_last_day'
          : 'invalid_resignation_action',
      'Cannot $action a $status resignation now',
    );
  }
  return next;
}

/// Bản đơn thôi việc đã tải lên kho của khu vực
typedef ResignationLetter = ({String key, String name, String mime});

/// Đơn nhận: Word, PDF, ảnh JPG/PNG
const resignationLetterTypes = {
  'application/pdf',
  'image/jpeg',
  'image/png',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
};

abstract interface class ResignationRepository {
  Future<List<Map<String, dynamic>>> list({String? employeeId, String? status});

  Future<Map<String, dynamic>?> find(int id);

  /// Ném `pending_exists`, `notice_too_short`, `archived`
  Future<Map<String, dynamic>> create(
    String employeeId, {
    required DateTime lastDay,
    required String reason,
    ResignationLetter? letter,
  });

  /// Khóa object của bản đơn; `null` nếu không có đơn hay chưa đính kèm
  Future<String?> letterKey(int id);

  Future<void> saveAnalysis(
    int id,
    Map<String, dynamic> analysis, {
    required String source,
  });

  Future<Map<String, dynamic>> setStatus(
    int id, {
    required String status,
    required String by,
    String? note,
  });
}

class PostgresResignationRepository implements ResignationRepository {
  PostgresResignationRepository(this._db);

  final Database _db;

  static const _columns =
      'r.id, r.employee_id, r.last_day, r.reason, r.status, r.decided_by, '
      "r.note, r.created_at, r.updated_at, e.family_name || ' ' || "
      'e.given_name as name, r.letter_name, r.ai_analysis, r.ai_source';

  @override
  Future<List<Map<String, dynamic>>> list({
    String? employeeId,
    String? status,
  }) async {
    final rows = await _db.query(
      'select $_columns from resignations r '
      'join employees e on e.id = r.employee_id '
      'where (@employee::text is null or r.employee_id = @employee) '
      'and (@status::text is null or r.status = @status) '
      'order by r.created_at desc limit 200',
      params: {'employee': employeeId, 'status': status},
      fromPrimary: true,
    );
    return [for (final r in rows) _json(r)];
  }

  @override
  Future<Map<String, dynamic>?> find(int id) async {
    final rows = await _db.query(
      'select $_columns from resignations r '
      'join employees e on e.id = r.employee_id where r.id = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    return rows.isEmpty ? null : _json(rows.first);
  }

  @override
  Future<Map<String, dynamic>> create(
    String employeeId, {
    required DateTime lastDay,
    required String reason,
    ResignationLetter? letter,
  }) async {
    checkNotice(lastDay, DateTime.now());
    final id = await _db.transaction((tx) async {
      final employee = await tx.execute(
        Sql.named('select status from employees where id = @id for update'),
        parameters: {'id': employeeId},
      );
      if (employee.isEmpty || employee.first[0] != 'active') {
        throw const ResignationViolation('archived', 'Employee is not active');
      }
      final open = await tx.execute(
        Sql.named(
          'select 1 from resignations where employee_id = @id '
          "and status in ('pending', 'approved')",
        ),
        parameters: {'id': employeeId},
      );
      if (open.isNotEmpty) {
        throw const ResignationViolation(
          'pending_exists',
          'A resignation is already open',
        );
      }
      final rows = await tx.execute(
        Sql.named(
          'insert into resignations (employee_id, last_day, reason, '
          'letter_key, letter_name, letter_mime) values (@id, @day, @reason, '
          '@key, @name, @mime) returning id',
        ),
        parameters: {
          'id': employeeId,
          'day': lastDay,
          'reason': reason,
          'key': letter?.key,
          'name': letter?.name,
          'mime': letter?.mime,
        },
      );
      final id = rows.first[0]! as int;
      await _outbox(tx, id, employeeId, 'ResignationRequested', lastDay);
      return id;
    });
    return (await find(id))!;
  }

  @override
  Future<String?> letterKey(int id) async {
    final rows = await _db.query(
      'select letter_key from resignations where id = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    return rows.isEmpty ? null : rows.first['letter_key'] as String?;
  }

  @override
  Future<void> saveAnalysis(
    int id,
    Map<String, dynamic> analysis, {
    required String source,
  }) => _db.execute(
    'update resignations set ai_analysis = @a::jsonb, ai_source = @s '
    'where id = @id',
    params: {'id': id, 'a': jsonEncode(analysis), 's': source},
  );

  @override
  Future<Map<String, dynamic>> setStatus(
    int id, {
    required String status,
    required String by,
    String? note,
  }) async {
    await _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'update resignations set status = @status, decided_by = @by, '
          'note = coalesce(@note, note), updated_at = now() where id = @id '
          'returning employee_id, last_day',
        ),
        parameters: {'id': id, 'status': status, 'by': by, 'note': note},
      );
      await _outbox(
        tx,
        id,
        rows.first[0]! as String,
        switch (status) {
          'approved' => 'ResignationApproved',
          'rejected' => 'ResignationRejected',
          'completed' => 'ResignationCompleted',
          _ => 'ResignationWithdrawn',
        },
        rows.first[1]! as DateTime,
      );
    });
    return (await find(id))!;
  }

  Future<void> _outbox(
    TxSession tx,
    int id,
    String employeeId,
    String type,
    DateTime lastDay,
  ) => addOutboxEvent(
    tx,
    aggregate: 'resignation',
    aggregateId: '$id',
    eventType: type,
    payload: {
      'resignationId': id,
      'employeeId': employeeId,
      'lastDay': lastDay.toIso8601String().substring(0, 10),
    },
  );

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'employeeId': r['employee_id'],
    'name': r['name'],
    'lastDay': (r['last_day'] as DateTime).toIso8601String().substring(0, 10),
    'reason': r['reason'],
    'status': r['status'],
    'decidedBy': r['decided_by'],
    'note': r['note'],
    'createdAt': (r['created_at'] as DateTime).toUtc().toIso8601String(),
    'updatedAt': (r['updated_at'] as DateTime).toUtc().toIso8601String(),
    'letterName': r['letter_name'],
    'aiAnalysis': r['ai_analysis'],
    'aiSource': r['ai_source'],
  };
}
