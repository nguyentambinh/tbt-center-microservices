/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:recruitment_service/src/imports/draft_rows.dart';
import 'package:tbt_common/tbt_common.dart';

/// Nhập ứng viên hàng loạt (R84): đọc tệp thành danh sách nháp, HR xác nhận
/// dòng nào thì dòng đó mới thành hồ sơ thật.
abstract interface class ImportRepository {
  Future<Map<String, dynamic>> createDraft({
    required String sourceType,
    required String sourceRef,
    required String importedBy,
    required List<DraftRow> rows,
  });

  /// `null` nếu không có đợt nhập này.
  Future<Map<String, dynamic>?> find(String id);

  /// Ghi các dòng [rowIds] (hoặc mọi dòng hợp lệ khi [rowIds] là `null`)
  /// thành hồ sơ: dòng "update" sửa hồ sơ trùng email/số điện thoại, dòng
  /// "create" thêm mới. Dòng đã xác nhận hoặc lỗi thì bỏ qua.
  Future<Map<String, dynamic>?> confirm(
    String id, {
    required String countryCode,
    required String confirmedBy,
    List<String>? rowIds,
  });
}

class PostgresImportRepository implements ImportRepository {
  PostgresImportRepository(this._db);

  final Database _db;

  @override
  Future<Map<String, dynamic>> createDraft({
    required String sourceType,
    required String sourceRef,
    required String importedBy,
    required List<DraftRow> rows,
  }) async {
    final id = await _db.transaction((tx) async {
      final created = await tx.execute(
        Sql.named(
          'insert into candidate_imports (source_type, source_ref, '
          'imported_by) values (@type, @ref, @by) returning id::text',
        ),
        parameters: {'type': sourceType, 'ref': sourceRef, 'by': importedBy},
      );
      final importId = created.first[0]! as String;
      for (final row in rows) {
        final match = row.error == null ? await _match(tx, row) : null;
        await tx.execute(
          Sql.named(
            'insert into candidate_import_rows (import_id, row_number, data, '
            'action, status, error, candidate_id) values (@import::uuid, '
            '@n, @data::jsonb, @action, @status, @error, @candidate::uuid)',
          ),
          parameters: {
            'import': importId,
            'n': row.rowNumber,
            'data': jsonEncode(row.toData()),
            'action': match == null ? 'create' : 'update',
            'status': row.error == null ? 'pending' : 'invalid',
            'error': row.error,
            'candidate': match,
          },
        );
      }
      return importId;
    });
    return (await find(id))!;
  }

  @override
  Future<Map<String, dynamic>?> find(String id) async {
    final head = await _db.query(
      'select id::text, source_type, source_ref, imported_by, created_at '
      'from candidate_imports where id::text = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    if (head.isEmpty) return null;
    final rows = await _db.query(
      'select id::text, row_number, data, action, status, error, '
      'candidate_id::text from candidate_import_rows '
      'where import_id::text = @id order by row_number',
      params: {'id': id},
      fromPrimary: true,
    );
    final h = head.first;
    return {
      'id': h['id'],
      'sourceType': h['source_type'],
      'sourceRef': h['source_ref'],
      'importedBy': h['imported_by'],
      'createdAt': (h['created_at'] as DateTime).toIso8601String(),
      'rows': [
        for (final r in rows)
          {
            'id': r['id'],
            'rowNumber': r['row_number'],
            ...(r['data'] as Map<String, dynamic>),
            'action': r['action'],
            'status': r['status'],
            'error': r['error'],
            'candidateId': r['candidate_id'],
          },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>?> confirm(
    String id, {
    required String countryCode,
    required String confirmedBy,
    List<String>? rowIds,
  }) async {
    final exists = await _db.query(
      'select 1 from candidate_imports where id::text = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    if (exists.isEmpty) return null;

    var accepted = 0;
    await _db.transaction((tx) async {
      // Khóa các dòng chờ: bấm xác nhận hai lần cùng lúc không ghi trùng.
      final pending = await tx.execute(
        Sql.named(
          'select id::text, data from candidate_import_rows '
          "where import_id::text = @id and status = 'pending' "
          'and (@all or id::text = any(@ids)) order by row_number for update',
        ),
        parameters: {
          'id': id,
          'all': rowIds == null,
          'ids': TypedValue(Type.textArray, rowIds ?? const <String>[]),
        },
      );
      for (final row in pending) {
        final rowId = row[0]! as String;
        final data = row[1]! as Map<String, dynamic>;
        final draft = DraftRow(
          rowNumber: 0,
          fullName: data['fullName'] as String,
          email: data['email'] as String?,
          phone: data['phone'] as String?,
          appliedPosition: data['appliedPosition'] as String?,
        );
        // Tìm lại lúc xác nhận: từ lúc tạo nháp có thể đã có người tự nộp.
        final match = await _match(tx, draft);
        final candidate = match == null
            ? await _create(tx, draft, countryCode, confirmedBy)
            : await _update(tx, match, draft);
        await tx.execute(
          Sql.named(
            "update candidate_import_rows set status = 'accepted', "
            'action = @action, candidate_id = @candidate::uuid '
            'where id::text = @row',
          ),
          parameters: {
            'row': rowId,
            'action': match == null ? 'create' : 'update',
            'candidate': candidate['candidateId'],
          },
        );
        await addOutboxEvent(
          tx,
          aggregate: 'candidate',
          aggregateId: candidate['candidateId']! as String,
          eventType: match == null
              ? 'CandidateApplied'
              : 'CandidateProfileUpdated',
          payload: {...candidate, 'source': 'import'},
        );
        accepted++;
      }
    });
    return {'accepted': accepted, 'import': await find(id)};
  }

  Future<String?> _match(TxSession tx, DraftRow row) async {
    final found = await tx.execute(
      Sql.named(
        'select id::text from candidates where '
        '(@email::text is not null and lower(email) = @email) or '
        '(@phone::text is not null and phone = @phone) limit 1',
      ),
      parameters: {'email': row.email, 'phone': row.phone},
    );
    return found.isEmpty ? null : found.first[0]! as String;
  }

  Future<Map<String, Object?>> _create(
    TxSession tx,
    DraftRow row,
    String countryCode,
    String by,
  ) async {
    final created = await tx.execute(
      Sql.named(
        'insert into candidates (country_code, full_name, email, phone, '
        'applied_position, source) values (@country, @name, @email, @phone, '
        "@position, 'import') returning id::text, status",
      ),
      parameters: {
        'country': countryCode,
        'name': row.fullName,
        'email': row.email,
        'phone': row.phone,
        'position': row.appliedPosition,
      },
    );
    final id = created.first[0]! as String;
    await tx.execute(
      Sql.named(
        'insert into candidate_status_history (candidate_id, status, note, '
        "changed_by) values (@id::uuid, 'submitted', 'Imported by HR', @by)",
      ),
      parameters: {'id': id, 'by': by},
    );
    return _event(id, countryCode, row.appliedPosition, 'submitted');
  }

  /// Chỉ điền thêm thông tin còn trống, không ghi đè dữ liệu ứng viên tự nhập.
  Future<Map<String, Object?>> _update(
    TxSession tx,
    String id,
    DraftRow row,
  ) async {
    final updated = await tx.execute(
      Sql.named(
        'update candidates set email = coalesce(email, @email), '
        'phone = coalesce(phone, @phone), '
        'applied_position = coalesce(applied_position, @position), '
        'updated_at = now() where id::text = @id '
        'returning country_code, applied_position, status',
      ),
      parameters: {
        'id': id,
        'email': row.email,
        'phone': row.phone,
        'position': row.appliedPosition,
      },
    );
    final r = updated.first;
    return _event(id, r[0]! as String, r[1] as String?, r[2]! as String);
  }

  /// Như sự kiện ứng viên khác: không mang email, số điện thoại lên Hub.
  Map<String, Object?> _event(
    String id,
    String countryCode,
    String? position,
    String status,
  ) => {
    'candidateId': id,
    'countryCode': countryCode,
    'appliedPosition': position,
    'status': status,
  };
}
