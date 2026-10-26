/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-26
 */

import 'dart:math';

import 'package:hr_service/src/data/organization_repository.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Danh mục chức vụ (cây chức vụ 1–6) do quản trị chỉnh; ghi sổ kiểm toán
abstract interface class PositionCatalog {
  /// Chức vụ kèm cấp, hệ số lương, số người đang giữ
  Future<List<Map<String, dynamic>>> list();

  Future<Map<String, dynamic>> create({
    required String name,
    required int level,
    required double coefficient,
    required String by,
  });

  /// `null` nếu không có chức vụ
  Future<Map<String, dynamic>?> update(
    String id, {
    required String by,
    String? name,
    int? level,
    double? coefficient,
  });

  /// Ném `in_use` khi còn người giữ chức vụ; `false` nếu không có
  Future<bool> delete(String id, {required String by});
}

void checkPosition({String? name, int? level, double? coefficient}) {
  if (name != null && name.trim().isEmpty) {
    throw const OrganizationViolation('invalid_body', 'Name is required');
  }
  if (level != null && (level < 1 || level > 6)) {
    throw const OrganizationViolation('invalid_body', 'Level must be 1-6');
  }
  if (coefficient != null && (coefficient <= 0 || coefficient > 20)) {
    throw const OrganizationViolation(
      'invalid_body',
      'Coefficient must be between 0 and 20',
    );
  }
}

class PostgresPositionCatalog implements PositionCatalog {
  PostgresPositionCatalog(this._db);

  final Database _db;

  @override
  Future<List<Map<String, dynamic>>> list() async {
    final rows = await _db.query(
      'select p.id, p.name, p.level, p.salary_coefficient::float8 as k, '
      '(select count(*)::int from employees e where e.position_id = p.id '
      "and e.status = 'active') as holders from positions p "
      'order by p.level desc, p.name',
      fromPrimary: true,
    );
    return [for (final r in rows) _json(r)];
  }

  @override
  Future<Map<String, dynamic>> create({
    required String name,
    required int level,
    required double coefficient,
    required String by,
  }) {
    checkPosition(name: name, level: level, coefficient: coefficient);
    return _db.transaction((tx) async {
      final id = 'CV${Random().nextInt(900000) + 100000}';
      final rows = await tx.execute(
        Sql.named(
          'insert into positions (id, name, level, salary_coefficient) '
          'values (@id, @name, @level, @k) returning id, name, level, '
          'salary_coefficient::float8 as k, 0 as holders',
        ),
        parameters: {
          'id': id,
          'name': name.trim(),
          'level': level,
          'k': coefficient,
        },
      );
      final position = _json(rows.first.toColumnMap());
      await _event(tx, 'PositionCreated', id, {...position, 'by': by});
      return position;
    });
  }

  @override
  Future<Map<String, dynamic>?> update(
    String id, {
    required String by,
    String? name,
    int? level,
    double? coefficient,
  }) {
    checkPosition(name: name, level: level, coefficient: coefficient);
    return _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'update positions set name = coalesce(@name, name), '
          'level = coalesce(@level, level), '
          'salary_coefficient = coalesce(@k, salary_coefficient) '
          'where id = @id returning id, name, level, '
          'salary_coefficient::float8 as k, (select count(*)::int from '
          'employees e where e.position_id = positions.id and e.status = '
          "'active') as holders",
        ),
        parameters: {
          'id': id,
          'name': name?.trim(),
          'level': level,
          'k': coefficient,
        },
      );
      if (rows.isEmpty) return null;
      final position = _json(rows.first.toColumnMap());
      await _event(tx, 'PositionUpdated', id, {...position, 'by': by});
      return position;
    });
  }

  @override
  Future<bool> delete(String id, {required String by}) =>
      _db.transaction((tx) async {
        final used = await tx.execute(
          Sql.named(
            'select count(*)::int from employees where position_id = @id',
          ),
          parameters: {'id': id},
        );
        if ((used.first[0]! as int) > 0) {
          throw const OrganizationViolation(
            'in_use',
            'Someone still holds this position',
          );
        }
        final deleted = await tx.execute(
          Sql.named('delete from positions where id = @id'),
          parameters: {'id': id},
        );
        if (deleted.affectedRows == 0) return false;
        await _event(tx, 'PositionDeleted', id, {'id': id, 'by': by});
        return true;
      });

  Future<void> _event(
    TxSession tx,
    String type,
    String id,
    Map<String, Object?> payload,
  ) => addOutboxEvent(
    tx,
    aggregate: 'position',
    aggregateId: id,
    eventType: type,
    payload: payload,
  );

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'name': r['name'],
    'level': r['level'],
    'coefficient': r['k'],
    'holders': r['holders'],
  };
}
