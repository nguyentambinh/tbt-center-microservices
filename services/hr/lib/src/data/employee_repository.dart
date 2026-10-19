/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:hr_service/src/domain/employee.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

abstract interface class EmployeeRepository {
  Future<Page<EmployeeSummary>> search({
    String? query,
    String? departmentId,
    int page = 1,
    int size = 30,
  });

  Future<EmployeeDetail?> find(String id);

  /// Tạo nhân viên mới tuyển, gọi lại không tạo trùng
  Future<EmployeeSummary> hire(NewHire hire);
}

class NewHire {
  const NewHire({
    required this.id,
    required this.countryCode,
    required this.familyName,
    required this.givenName,
    required this.email,
    this.phone,
    this.positionName,
  });

  final String id;
  final String countryCode;
  final String familyName;
  final String givenName;
  final String email;
  final String? phone;
  final String? positionName;
}

class PostgresEmployeeRepository implements EmployeeRepository {
  PostgresEmployeeRepository(this._db);

  final Database _db;

  static const _summaryColumns = '''
    e.id, e.family_name, e.given_name, e.email, e.photo_url,
    p.name as position, d.name as department, c.name as company''';

  static const _joins = '''
    from employees e
    left join positions p on p.id = e.position_id
    left join departments d on d.id = e.department_id
    left join companies c on c.id = e.company_id''';

  @override
  Future<Page<EmployeeSummary>> search({
    String? query,
    String? departmentId,
    int page = 1,
    int size = 30,
  }) async {
    const nameMatches = "e.family_name || ' ' || e.given_name ilike @q";
    final where = [
      if (query != null && query.isNotEmpty)
        '($nameMatches or e.id ilike @q or e.email ilike @q)',
      if (departmentId != null) 'e.department_id = @department',
    ];
    final whereSql = where.isEmpty ? '' : 'where ${where.join(' and ')}';
    final params = <String, Object?>{
      if (query != null && query.isNotEmpty) 'q': '%$query%',
      if (departmentId != null) 'department': departmentId,
    };

    final count = await _db.query(
      'select count(*) as n $_joins $whereSql',
      params: params,
    );
    final rows = await _db.query(
      'select $_summaryColumns $_joins $whereSql '
      'order by e.given_name, e.family_name limit @limit offset @offset',
      params: {...params, 'limit': size, 'offset': (page - 1) * size},
    );

    return Page(
      [for (final row in rows) _summary(row)],
      total: count.first['n'] as int,
      page: page,
      size: size,
    );
  }

  @override
  Future<EmployeeDetail?> find(String id) async {
    final rows = await _db.query(
      'select $_summaryColumns, e.birth_year, e.gender, e.labor_contract, '
      'e.hired_on, e.department_id, e.company_id $_joins where e.id = @id',
      params: {'id': id},
    );
    if (rows.isEmpty) return null;
    final row = rows.first;

    final contact = await _db.query(
      'select phone, address, facebook, x_handle as "xHandle", '
      'hometown_code as "hometownCode" from contacts where employee_id = @id',
      params: {'id': id},
    );
    final health = await _db.query(
      'select height_cm as "heightCm", weight_kg as "weightKg", '
      'medical_history as "medicalHistory", vision_score as "visionScore", '
      'updated_on as "updatedOn" from health_records where employee_id = @id',
      params: {'id': id},
    );
    final insurance = await _db.query(
      'select insurance_type as "type", insurance_number as "number", '
      'expires_on as "expiresOn" from insurances where employee_id = @id',
      params: {'id': id},
    );
    final relatives = await _db.query(
      'select full_name as "fullName", phone, address, relationship '
      'from relatives where employee_id = @id order by full_name',
      params: {'id': id},
    );

    return EmployeeDetail(
      summary: _summary(row),
      work: _jsonSafe({
        'birthYear': row['birth_year'],
        'gender': row['gender'],
        'laborContract': row['labor_contract'],
        'hiredOn': row['hired_on'],
        'departmentId': row['department_id'],
        'companyId': row['company_id'],
      }),
      contact: contact.isEmpty ? null : _jsonSafe(contact.first),
      health: health.isEmpty ? null : _jsonSafe(health.first),
      insurance: insurance.isEmpty ? null : _jsonSafe(insurance.first),
      relatives: [for (final r in relatives) _jsonSafe(r)],
    );
  }

  @override
  Future<EmployeeSummary> hire(NewHire hire) async {
    await _db.transaction((tx) async {
      // Chức danh khớp tên thì gắn luôn
      await tx.execute(
        Sql.named(
          'insert into employees (id, company_id, country_code, family_name, '
          'given_name, email, position_id, hired_on) '
          'select @id, (select id from companies where country_code = @country '
          'order by id limit 1), @country, @family, @given, @email, '
          '(select id from positions where lower(name) = lower(@position) '
          'limit 1), current_date '
          'on conflict (id) do nothing',
        ),
        parameters: {
          'id': hire.id,
          'country': hire.countryCode,
          'family': hire.familyName,
          'given': hire.givenName,
          'email': hire.email,
          'position': hire.positionName ?? '',
        },
      );
      if (hire.phone != null) {
        await tx.execute(
          Sql.named(
            'insert into contacts (employee_id, phone) values (@id, @phone) '
            'on conflict (employee_id) do nothing',
          ),
          parameters: {'id': hire.id, 'phone': hire.phone},
        );
      }
    });
    final rows = await _db.query(
      'select $_summaryColumns $_joins where e.id = @id',
      params: {'id': hire.id},
      fromPrimary: true,
    );
    return _summary(rows.first);
  }

  EmployeeSummary _summary(Map<String, dynamic> row) => EmployeeSummary(
    id: row['id'] as String,
    familyName: row['family_name'] as String,
    givenName: row['given_name'] as String,
    email: row['email'] as String?,
    photoUrl: row['photo_url'] as String?,
    position: row['position'] as String?,
    department: row['department'] as String?,
    company: row['company'] as String?,
  );

  /// Cột date trả về DateTime, đổi sang chuỗi `YYYY-MM-DD` để ra JSON.
  Map<String, dynamic> _jsonSafe(Map<String, dynamic> row) => {
    for (final entry in row.entries)
      entry.key: switch (entry.value) {
        final DateTime d => d.toIso8601String().substring(0, 10),
        final other => other,
      },
  };
}
