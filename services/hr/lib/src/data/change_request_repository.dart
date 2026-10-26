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

/// Trường nhân viên được đề xuất sửa: tên trong API → (bảng, cột)
const editableFields = <String, (String, String)>{
  'email': ('employees', 'email'),
  'phone': ('contacts', 'phone'),
  'address': ('contacts', 'address'),
  'facebook': ('contacts', 'facebook'),
  'xHandle': ('contacts', 'x_handle'),
  'hometownCode': ('contacts', 'hometown_code'),
  'heightCm': ('health_records', 'height_cm'),
  'weightKg': ('health_records', 'weight_kg'),
  'visionScore': ('health_records', 'vision_score'),
  'medicalHistory': ('health_records', 'medical_history'),
};

const _numberFields = {'heightCm', 'weightKg', 'visionScore'};

class ChangeRequestViolation implements Exception {
  const ChangeRequestViolation(this.code, this.message);

  final String code;
  final String message;
}

abstract interface class ChangeRequestRepository {
  /// Ném [ChangeRequestViolation] `pending_exists` khi đã có đề xuất đang chờ.
  Future<Map<String, dynamic>> create(
    String employeeId,
    Map<String, Object?> changes, {
    String? reason,
  });

  Future<List<Map<String, dynamic>>> mine(String employeeId);

  /// Đề xuất theo trạng thái, kèm tên nhân viên; null là mọi trạng thái.
  Future<List<Map<String, dynamic>>> list({String? status});

  /// Duyệt thì ghi thay đổi vào hồ sơ; `null` nếu không có đề xuất.
  /// Ném [ChangeRequestViolation] `already_decided`.
  Future<Map<String, dynamic>?> decide(
    int id, {
    required bool approve,
    required String decidedBy,
    String? note,
  });
}

/// Kiểm danh sách thay đổi: chỉ trường cho phép, số đo là số nguyên dương.
Map<String, Object?> validateChanges(Map<String, Object?> raw) {
  if (raw.isEmpty) {
    throw const ChangeRequestViolation('empty', 'No changes');
  }
  final out = <String, Object?>{};
  for (final entry in raw.entries) {
    if (!editableFields.containsKey(entry.key)) {
      throw ChangeRequestViolation('field_not_editable', entry.key);
    }
    final value = entry.value;
    if (_numberFields.contains(entry.key)) {
      final n = value is num ? value.toInt() : int.tryParse('$value');
      if (n == null || n <= 0) {
        throw ChangeRequestViolation('invalid_value', entry.key);
      }
      out[entry.key] = n;
    } else {
      final text = value?.toString().trim() ?? '';
      if (entry.key == 'email' &&
          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
        throw const ChangeRequestViolation('invalid_value', 'email');
      }
      out[entry.key] = text.isEmpty ? null : text;
    }
  }
  return out;
}

class PostgresChangeRequestRepository implements ChangeRequestRepository {
  PostgresChangeRequestRepository(this._db);

  final Database _db;

  static const _from =
      'from employee_change_requests r '
      'join employees e on e.id = r.employee_id';

  static const _columns = '''
r.id, r.employee_id, r.changes, r.reason, r.status, r.requested_at,
r.decided_by, r.decided_at, r.note, e.family_name, e.given_name''';

  @override
  Future<Map<String, dynamic>> create(
    String employeeId,
    Map<String, Object?> changes, {
    String? reason,
  }) async {
    final valid = validateChanges(changes);
    return _db.transaction((tx) async {
      final pending = await tx.execute(
        Sql.named(
          'select 1 from employee_change_requests '
          "where employee_id = @id and status = 'pending'",
        ),
        parameters: {'id': employeeId},
      );
      if (pending.isNotEmpty) {
        throw const ChangeRequestViolation(
          'pending_exists',
          'A request is waiting for HR',
        );
      }
      final rows = await tx.execute(
        Sql.named(
          'insert into employee_change_requests (employee_id, changes, reason) '
          'values (@id, @changes::jsonb, @reason) returning id, requested_at',
        ),
        parameters: {
          'id': employeeId,
          'changes': jsonEncode(valid),
          'reason': reason,
        },
      );
      final id = rows.first[0]! as int;
      await addOutboxEvent(
        tx,
        aggregate: 'employee',
        aggregateId: employeeId,
        eventType: 'ProfileChangeRequested',
        payload: {
          'requestId': id,
          'employeeId': employeeId,
          'fields': valid.keys.toList(),
        },
      );
      return {
        'id': id,
        'employeeId': employeeId,
        'changes': valid,
        'reason': reason,
        'status': 'pending',
        'requestedAt': (rows.first[1]! as DateTime).toIso8601String(),
      };
    });
  }

  @override
  Future<List<Map<String, dynamic>>> mine(String employeeId) async {
    final rows = await _db.query(
      'select $_columns $_from '
      'where r.employee_id = @id order by r.requested_at desc limit 20',
      params: {'id': employeeId},
      fromPrimary: true,
    );
    return [for (final r in rows) _json(r)];
  }

  @override
  Future<List<Map<String, dynamic>>> list({String? status}) async {
    final rows = await _db.query(
      'select $_columns $_from '
      'where @status::text is null or r.status = @status '
      'order by r.requested_at desc limit 200',
      params: {'status': status},
      fromPrimary: true,
    );
    return [for (final r in rows) _json(r)];
  }

  @override
  Future<Map<String, dynamic>?> decide(
    int id, {
    required bool approve,
    required String decidedBy,
    String? note,
  }) async {
    final done = await _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'select employee_id, changes, status '
          'from employee_change_requests where id = @id for update',
        ),
        parameters: {'id': id},
      );
      if (rows.isEmpty) return false;
      final employeeId = rows.first[0]! as String;
      final changes = (rows.first[1]! as Map).cast<String, Object?>();
      if (rows.first[2] != 'pending') {
        throw const ChangeRequestViolation(
          'already_decided',
          'Request already decided',
        );
      }
      if (employeeId == decidedBy) {
        throw const ChangeRequestViolation(
          'self_approval',
          'Your own request goes to someone else',
        );
      }
      if (approve) await _apply(tx, employeeId, changes);
      await tx.execute(
        Sql.named(
          'update employee_change_requests '
          'set status = @status, decided_by = @by, '
          'decided_at = now(), note = @note where id = @id',
        ),
        parameters: {
          'id': id,
          'status': approve ? 'approved' : 'rejected',
          'by': decidedBy,
          'note': note,
        },
      );
      await addOutboxEvent(
        tx,
        aggregate: 'employee',
        aggregateId: employeeId,
        eventType: approve ? 'ProfileChangeApproved' : 'ProfileChangeRejected',
        payload: {
          'requestId': id,
          'employeeId': employeeId,
          'fields': changes.keys.toList(),
          'note': note,
        },
      );
      return true;
    });
    if (!done) return null;
    final rows = await _db.query(
      'select $_columns $_from where r.id = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    return _json(rows.first);
  }

  /// Ghi từng nhóm trường vào đúng bảng; liên hệ, sức khỏe chưa có thì tạo
  Future<void> _apply(
    TxSession tx,
    String employeeId,
    Map<String, Object?> changes,
  ) async {
    final byTable = <String, Map<String, Object?>>{};
    for (final entry in changes.entries) {
      final (table, column) = editableFields[entry.key]!;
      (byTable[table] ??= {})[column] = entry.value;
    }
    for (final MapEntry(key: table, value: columns) in byTable.entries) {
      final names = columns.keys.toList();
      final params = <String, Object?>{
        'id': employeeId,
        for (var i = 0; i < names.length; i++) 'v$i': columns[names[i]],
      };
      final set = [for (var i = 0; i < names.length; i++) '${names[i]} = @v$i']
          .join(', ');
      if (table == 'employees') {
        await tx.execute(
          Sql.named('update employees set $set where id = @id'),
          parameters: params,
        );
        continue;
      }
      final extra = table == 'health_records' ? ', updated_on' : '';
      final extraValue = table == 'health_records' ? ', current_date' : '';
      final extraSet = table == 'health_records'
          ? ', updated_on = current_date'
          : '';
      final cols = [for (var i = 0; i < names.length; i++) names[i]].join(', ');
      final vals = [for (var i = 0; i < names.length; i++) '@v$i'].join(', ');
      await tx.execute(
        Sql.named(
          'insert into $table (employee_id, $cols$extra) '
          'values (@id, $vals$extraValue) '
          'on conflict (employee_id) do update set $set$extraSet',
        ),
        parameters: params,
      );
    }
  }

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'employeeId': r['employee_id'],
    'employeeName': '${r['family_name']} ${r['given_name']}',
    'changes': r['changes'],
    'reason': r['reason'],
    'status': r['status'],
    'requestedAt': (r['requested_at'] as DateTime).toIso8601String(),
    'decidedBy': r['decided_by'],
    'decidedAt': (r['decided_at'] as DateTime?)?.toIso8601String(),
    'note': r['note'],
  };
}
