/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:math';

import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Lý do giải thể phòng ban
const dissolutionReasons = {
  'no_longer_needed',
  'restructured',
  'underperforming',
  'outsourced',
  'business_closed',
};

/// Thăng chức theo cây chức vụ: chức vụ mới phải có trong danh mục và cấp
/// cao hơn chức vụ hiện tại
void checkPromotion({required int currentLevel, required int? targetLevel}) {
  if (targetLevel == null) {
    throw const OrganizationViolation(
      'unknown_position',
      'Pick a position from the list',
    );
  }
  if (targetLevel <= currentLevel) {
    throw const OrganizationViolation(
      'not_higher_position',
      'Promotion must be to a higher level',
    );
  }
}

class OrganizationViolation implements Exception {
  const OrganizationViolation(this.code, this.message);

  final String code;
  final String message;
}

abstract interface class OrganizationRepository {
  /// Phòng ban kèm công ty, trưởng phòng, số người đang làm
  Future<List<Map<String, dynamic>>> departments();

  /// Cây tổ chức: công ty → phòng ban → người (cấp chức vụ, trưởng phòng)
  Future<Map<String, dynamic>> orgTree();

  /// Chức vụ cấp cao hơn chức vụ hiện tại của nhân viên (để đề cử)
  Future<List<Map<String, dynamic>>> positionsAbove(String employeeId);

  /// `null` nếu không có phòng; thành viên chưa xếp thứ tự
  Future<Map<String, dynamic>?> department(String id);

  Future<Map<String, dynamic>> createDepartment({
    required String name,
    required String companyId,
    required String createdBy,
  });

  /// Ném `members_remaining` khi còn người mà chưa chọn phòng nhận
  Future<Map<String, dynamic>> dissolve(
    String id, {
    required String reasonCode,
    required String dissolvedBy,
    String? note,
    String? mergeInto,
  });

  /// Ném `is_head`, `last_member`, `same_department`, `archived`
  Future<void> transfer(
    String employeeId, {
    required String toDepartment,
    required String by,
  });

  /// Ném `not_member` nếu nhân viên không thuộc phòng
  Future<void> setHead(
    String departmentId,
    String employeeId, {
    required String by,
  });

  /// Nhân viên đang làm chưa có phòng ban (mới nhận việc)
  Future<List<Map<String, dynamic>>> unassigned();

  /// Ném `last_member` khi là người cuối cùng của phòng
  Future<void> archive(
    String employeeId, {
    required String reason,
    required String by,
  });

  Future<void> restore(String employeeId, {required String by});

  Future<Map<String, List<Map<String, dynamic>>>> filters();

  /// Nhân viên đang làm với chức vụ, phòng ban (cho xếp hạng)
  Future<List<Map<String, dynamic>>> activeEmployees({String? departmentId});

  /// Ném `pending_exists`, `archived`. `groupRole` (hr, finance) là đề cử lên
  /// phòng Nhân sự, Tài chính tập đoàn; chức vụ mới lấy theo vai trò đó
  Future<Map<String, dynamic>> nominate({
    required String employeeId,
    required String proposedPosition,
    required double raisePercent,
    required String reason,
    required String nominatedBy,
    String? groupRole,
  });

  Future<List<Map<String, dynamic>>> nominations({String? status});

  /// Duyệt thì đổi chức vụ; `null` nếu không có đề cử. Đề cử lên cấp tập đoàn
  /// chỉ văn phòng tập đoàn duyệt (`groupDecider`), không thì ném `group_only`
  Future<Map<String, dynamic>?> decideNomination(
    int id, {
    required bool approve,
    required String decidedBy,
    String? note,
    bool groupDecider = false,
  });

  /// Văn phòng quản lý đổi chức vụ có hiệu lực ngay, không qua duyệt.
  /// `promote` thì chức vụ mới phải cấp cao hơn. Ném `not_found`, `archived`,
  /// `unknown_position`, `not_higher_position`, `same_position`
  Future<Map<String, dynamic>> changePosition(
    String employeeId, {
    required String positionId,
    required bool promote,
    required String by,
    String? reason,
  });
}

class PostgresOrganizationRepository implements OrganizationRepository {
  PostgresOrganizationRepository(this._db, {this.media});

  final Database _db;
  final MediaStore? media;

  @override
  Future<List<Map<String, dynamic>>> departments() async {
    final rows = await _db.query(
      'select d.id, d.name, d.company_id, c.name as company, d.manager_id, '
      "h.family_name || ' ' || h.given_name as head_name, "
      '(select count(*)::int from employees e '
      "where e.department_id = d.id and e.status = 'active') as members "
      'from departments d left join companies c on c.id = d.company_id '
      'left join employees h on h.id = d.manager_id order by d.name, d.id',
    );
    return [
      for (final r in rows)
        {
          'id': r['id'],
          'name': r['name'],
          'companyId': r['company_id'],
          'company': r['company'],
          'headId': r['manager_id'],
          'headName': r['head_name'],
          'members': r['members'],
        },
    ];
  }

  @override
  Future<Map<String, dynamic>?> department(String id) async {
    final all = await departments();
    final found = all.where((d) => d['id'] == id).toList();
    if (found.isEmpty) return null;
    final rows = await _db.query(
      'select e.id, e.family_name, e.given_name, e.photo_url, e.hired_on, '
      'p.name as position from employees e '
      'left join positions p on p.id = e.position_id '
      "where e.department_id = @id and e.status = 'active'",
      params: {'id': id},
      fromPrimary: true,
    );
    return {
      ...found.first,
      'memberList': [for (final r in rows) _person(r)],
    };
  }

  @override
  Future<Map<String, dynamic>> createDepartment({
    required String name,
    required String companyId,
    required String createdBy,
  }) => _db.transaction((tx) async {
    final company = await tx.execute(
      Sql.named('select country_code from companies where id = @id'),
      parameters: {'id': companyId},
    );
    if (company.isEmpty) {
      throw const OrganizationViolation('unknown_company', 'No such company');
    }
    final id = 'PB${Random().nextInt(900000) + 100000}';
    await tx.execute(
      Sql.named(
        'insert into departments (id, company_id, country_code, name) '
        'values (@id, @company, @country, @name)',
      ),
      parameters: {
        'id': id,
        'company': companyId,
        'country': company.first[0],
        'name': name,
      },
    );
    await addOutboxEvent(
      tx,
      aggregate: 'department',
      aggregateId: id,
      eventType: 'DepartmentCreated',
      payload: {'departmentId': id, 'name': name, 'by': createdBy},
    );
    return {'id': id, 'name': name, 'companyId': companyId, 'members': 0};
  });

  @override
  Future<Map<String, dynamic>> dissolve(
    String id, {
    required String reasonCode,
    required String dissolvedBy,
    String? note,
    String? mergeInto,
  }) => _db.transaction((tx) async {
    if (!dissolutionReasons.contains(reasonCode)) {
      throw const OrganizationViolation('invalid_reason', 'Unknown reason');
    }
    final dept = await tx.execute(
      Sql.named(
        'select name, company_id from departments where id = @id for update',
      ),
      parameters: {'id': id},
    );
    if (dept.isEmpty) {
      throw const OrganizationViolation('not_found', 'No such department');
    }
    final members = await tx.execute(
      Sql.named(
        'select count(*)::int from employees where department_id = @id '
        "and status = 'active'",
      ),
      parameters: {'id': id},
    );
    final count = members.first[0]! as int;
    if (count > 0 && (mergeInto == null || mergeInto == id)) {
      throw const OrganizationViolation(
        'members_remaining',
        'Choose a department to receive the members',
      );
    }
    if (mergeInto != null) {
      final target = await tx.execute(
        Sql.named('select 1 from departments where id = @id'),
        parameters: {'id': mergeInto},
      );
      if (target.isEmpty) {
        throw const OrganizationViolation('not_found', 'No target department');
      }
    }
    // Chuyển mọi người (cả người bảo lưu) sang phòng nhận
    await tx.execute(
      Sql.named(
        'update employees set department_id = @to where department_id = @id',
      ),
      parameters: {'id': id, 'to': mergeInto},
    );
    await tx.execute(
      Sql.named('delete from departments where id = @id'),
      parameters: {'id': id},
    );
    await tx.execute(
      Sql.named(
        'insert into department_dissolutions (department_id, name, company_id, '
        'reason_code, note, merged_into, members_moved, dissolved_by) values '
        '(@id, @name, @company, @reason, @note, @merge, @moved, @by)',
      ),
      parameters: {
        'id': id,
        'name': dept.first[0],
        'company': dept.first[1],
        'reason': reasonCode,
        'note': note,
        'merge': mergeInto,
        'moved': count,
        'by': dissolvedBy,
      },
    );
    await addOutboxEvent(
      tx,
      aggregate: 'department',
      aggregateId: id,
      eventType: 'DepartmentDissolved',
      payload: {
        'departmentId': id,
        'name': dept.first[0],
        'reasonCode': reasonCode,
        'mergedInto': mergeInto,
        'membersMoved': count,
      },
    );
    return {'id': id, 'membersMoved': count, 'mergedInto': mergeInto};
  });

  @override
  Future<void> transfer(
    String employeeId, {
    required String toDepartment,
    required String by,
  }) => _db.transaction((tx) async {
    final rows = await tx.execute(
      Sql.named(
        'select e.department_id, e.status, '
        '(select manager_id from departments where id = e.department_id) '
        'from employees e where e.id = @id for update',
      ),
      parameters: {'id': employeeId},
    );
    if (rows.isEmpty) {
      throw const OrganizationViolation('not_found', 'No such employee');
    }
    final from = rows.first[0] as String?;
    if (rows.first[1] != 'active') {
      throw const OrganizationViolation('archived', 'Employee is archived');
    }
    if (from == toDepartment) {
      throw const OrganizationViolation('same_department', 'Already there');
    }
    // Trưởng phòng phải được thay bằng người khác trước khi điều chuyển
    if (rows.first[2] == employeeId) {
      throw const OrganizationViolation('is_head', 'Department heads stay');
    }
    final target = await tx.execute(
      Sql.named('select 1 from departments where id = @id'),
      parameters: {'id': toDepartment},
    );
    if (target.isEmpty) {
      throw const OrganizationViolation('not_found', 'No such department');
    }
    if (from != null) {
      final left = await tx.execute(
        Sql.named(
          'select count(*)::int from employees where department_id = @id '
          "and status = 'active'",
        ),
        parameters: {'id': from},
      );
      if ((left.first[0]! as int) <= 1) {
        throw const OrganizationViolation(
          'last_member',
          'A department must keep at least one member',
        );
      }
    }
    await tx.execute(
      Sql.named('update employees set department_id = @to where id = @id'),
      parameters: {'id': employeeId, 'to': toDepartment},
    );
    await addOutboxEvent(
      tx,
      aggregate: 'employee',
      aggregateId: employeeId,
      eventType: 'EmployeeTransferred',
      payload: {
        'employeeId': employeeId,
        'fromDepartment': from,
        'toDepartment': toDepartment,
        'by': by,
      },
    );
  });

  @override
  Future<void> setHead(
    String departmentId,
    String employeeId, {
    required String by,
  }) => _db.transaction((tx) async {
    final rows = await tx.execute(
      Sql.named(
        'select 1 from employees where id = @id and department_id = @dept '
        "and status = 'active'",
      ),
      parameters: {'id': employeeId, 'dept': departmentId},
    );
    if (rows.isEmpty) {
      throw const OrganizationViolation('not_member', 'Not in department');
    }
    await tx.execute(
      Sql.named('update departments set manager_id = @id where id = @dept'),
      parameters: {'id': employeeId, 'dept': departmentId},
    );
    await addOutboxEvent(
      tx,
      aggregate: 'department',
      aggregateId: departmentId,
      eventType: 'DepartmentHeadChanged',
      payload: {
        'departmentId': departmentId,
        'employeeId': employeeId,
        'by': by,
      },
    );
  });

  @override
  Future<List<Map<String, dynamic>>> unassigned() async {
    final rows = await _db.query(
      'select e.id, e.family_name, e.given_name, e.photo_url, e.hired_on, '
      'p.name as position from employees e '
      'left join positions p on p.id = e.position_id '
      "where e.department_id is null and e.status = 'active' "
      'order by e.hired_on desc nulls last',
      fromPrimary: true,
    );
    return [for (final r in rows) _person(r)];
  }

  @override
  Future<void> archive(
    String employeeId, {
    required String reason,
    required String by,
  }) => _db.transaction((tx) async {
    final rows = await tx.execute(
      Sql.named(
        'select department_id, status from employees where id = @id for update',
      ),
      parameters: {'id': employeeId},
    );
    if (rows.isEmpty) {
      throw const OrganizationViolation('not_found', 'No such employee');
    }
    if (rows.first[1] == 'archived') {
      throw const OrganizationViolation('archived', 'Already archived');
    }
    final dept = rows.first[0] as String?;
    if (dept != null) {
      final left = await tx.execute(
        Sql.named(
          'select count(*)::int from employees where department_id = @id '
          "and status = 'active'",
        ),
        parameters: {'id': dept},
      );
      if ((left.first[0]! as int) <= 1) {
        throw const OrganizationViolation(
          'last_member',
          'A department must keep at least one member',
        );
      }
      await tx.execute(
        Sql.named(
          'update departments set manager_id = null '
          'where id = @dept and manager_id = @id',
        ),
        parameters: {'id': employeeId, 'dept': dept},
      );
    }
    await tx.execute(
      Sql.named(
        "update employees set status = 'archived', archived_at = now(), "
        'archived_reason = @reason where id = @id',
      ),
      parameters: {'id': employeeId, 'reason': reason},
    );
    await addOutboxEvent(
      tx,
      aggregate: 'employee',
      aggregateId: employeeId,
      eventType: 'EmployeeArchived',
      payload: {'employeeId': employeeId, 'reason': reason, 'by': by},
    );
  });

  @override
  Future<void> restore(String employeeId, {required String by}) =>
      _db.transaction((tx) async {
        final rows = await tx.execute(
          Sql.named(
            "update employees set status = 'active', archived_at = null, "
            "archived_reason = null where id = @id and status = 'archived' "
            'returning id',
          ),
          parameters: {'id': employeeId},
        );
        if (rows.isEmpty) {
          throw const OrganizationViolation('not_archived', 'Not archived');
        }
        await addOutboxEvent(
          tx,
          aggregate: 'employee',
          aggregateId: employeeId,
          eventType: 'EmployeeRestored',
          payload: {'employeeId': employeeId, 'by': by},
        );
      });

  @override
  Future<Map<String, List<Map<String, dynamic>>>> filters() async {
    Future<List<Map<String, dynamic>>> list(String sql) async => [
      for (final r in await _db.query(sql)) {'id': r['id'], 'name': r['name']},
    ];
    return {
      'departments': await list(
        'select id, name from departments order by name',
      ),
      'positions': await list(
        'select distinct p.id, p.name from positions p '
        'join employees e on e.position_id = p.id order by p.name',
      ),
      'companies': await list('select id, name from companies order by name'),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> activeEmployees({
    String? departmentId,
  }) async {
    final rows = await _db.query(
      'select e.id, e.family_name, e.given_name, e.photo_url, e.hired_on, '
      'p.name as position, d.id as department_id, d.name as department '
      'from employees e left join positions p on p.id = e.position_id '
      'left join departments d on d.id = e.department_id '
      "where e.status = 'active' "
      'and (@dept::text is null or e.department_id = @dept)',
      params: {'dept': departmentId},
    );
    return [
      for (final r in rows)
        {
          ..._person(r),
          'departmentId': r['department_id'],
          'department': r['department'],
        },
    ];
  }

  @override
  Future<Map<String, dynamic>> nominate({
    required String employeeId,
    required String proposedPosition,
    required double raisePercent,
    required String reason,
    required String nominatedBy,
    String? groupRole,
  }) => _db.transaction((tx) async {
    var position = proposedPosition;
    if (groupRole != null && groupRole != 'hr' && groupRole != 'finance') {
      throw const OrganizationViolation(
        'invalid_body',
        'groupRole must be hr or finance',
      );
    }
    if (groupRole != null) {
      final target = await tx.execute(
        Sql.named('select name from positions where id = @id'),
        parameters: {'id': groupRole == 'hr' ? 'GRP-HR' : 'GRP-FIN'},
      );
      if (target.isEmpty) {
        throw const OrganizationViolation(
          'unknown_position',
          'Group positions are missing',
        );
      }
      position = target.first[0]! as String;
    }
    if (raisePercent <= 0 || raisePercent > 100) {
      throw const OrganizationViolation('invalid_raise', 'Raise must be > 0');
    }
    if (employeeId == nominatedBy) {
      throw const OrganizationViolation(
        'self_approval',
        'You cannot nominate yourself',
      );
    }
    final rows = await tx.execute(
      Sql.named(
        'select e.status, p.name, coalesce(p.level, 1) from employees e '
        'left join positions p on p.id = e.position_id where e.id = @id',
      ),
      parameters: {'id': employeeId},
    );
    final target = await tx.execute(
      Sql.named(
        'select level from positions where lower(name) = lower(@name) '
        'order by level desc limit 1',
      ),
      parameters: {'name': position},
    );
    if (rows.isEmpty) {
      throw const OrganizationViolation('not_found', 'No such employee');
    }
    if (rows.first[0] != 'active') {
      throw const OrganizationViolation('archived', 'Employee is archived');
    }
    checkPromotion(
      currentLevel: rows.first[2]! as int,
      targetLevel: target.isEmpty ? null : target.first[0]! as int,
    );
    final pending = await tx.execute(
      Sql.named(
        'select 1 from promotion_nominations '
        "where employee_id = @id and status = 'pending'",
      ),
      parameters: {'id': employeeId},
    );
    if (pending.isNotEmpty) {
      throw const OrganizationViolation('pending_exists', 'Already nominated');
    }
    final inserted = await tx.execute(
      Sql.named(
        'insert into promotion_nominations (employee_id, nominated_by, '
        'current_position, proposed_position, raise_percent, reason, scope, '
        'group_role) values (@id, @by, @current, @proposed, @raise, @reason, '
        '@scope, @groupRole) returning id',
      ),
      parameters: {
        'id': employeeId,
        'by': nominatedBy,
        'current': rows.first[1],
        'proposed': position,
        'raise': raisePercent,
        'reason': reason,
        'scope': groupRole == null ? 'region' : 'group',
        'groupRole': groupRole,
      },
    );
    final id = inserted.first[0]! as int;
    await addOutboxEvent(
      tx,
      aggregate: 'employee',
      aggregateId: employeeId,
      eventType: 'PromotionNominated',
      payload: {
        'nominationId': id,
        'employeeId': employeeId,
        'proposedPosition': position,
        'raisePercent': raisePercent,
        'groupRole': groupRole,
      },
    );
    return {
      'id': id,
      'employeeId': employeeId,
      'status': 'pending',
      'scope': groupRole == null ? 'region' : 'group',
      'groupRole': groupRole,
    };
  });

  @override
  Future<List<Map<String, dynamic>>> nominations({String? status}) async {
    final rows = await _db.query(
      'select n.*, e.family_name, e.given_name, e.photo_url '
      'from promotion_nominations n join employees e on e.id = n.employee_id '
      'where @status::text is null or n.status = @status '
      'order by n.created_at desc limit 200',
      params: {'status': status},
      fromPrimary: true,
    );
    return [for (final r in rows) _nomination(r)];
  }

  @override
  Future<Map<String, dynamic>?> decideNomination(
    int id, {
    required bool approve,
    required String decidedBy,
    String? note,
    bool groupDecider = false,
  }) async {
    final found = await _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'select employee_id, proposed_position, raise_percent::float8, '
          'status, scope '
          'from promotion_nominations where id = @id for update',
        ),
        parameters: {'id': id},
      );
      if (rows.isEmpty) return false;
      if (rows.first[3] != 'pending') {
        throw const OrganizationViolation('already_decided', 'Already decided');
      }
      if (rows.first[4] == 'group' && !groupDecider) {
        throw const OrganizationViolation(
          'group_only',
          'Only the group executive office decides group-level nominations',
        );
      }
      final employeeId = rows.first[0]! as String;
      final position = rows.first[1]! as String;
      if (employeeId == decidedBy) {
        throw const OrganizationViolation(
          'self_approval',
          'Your own nomination goes to someone else',
        );
      }
      if (approve) {
        // Chức vụ mới chưa có trong danh mục thì thêm vào
        await tx.execute(
          Sql.named(
            'insert into positions (id, name) select @pid, @name '
            'where not exists (select 1 from positions '
            'where lower(name) = lower(@name))',
          ),
          parameters: {
            'pid': 'CV${Random().nextInt(900000) + 100000}',
            'name': position,
          },
        );
        await tx.execute(
          Sql.named(
            'update employees set position_id = (select id from positions '
            'where lower(name) = lower(@name) limit 1) where id = @id',
          ),
          parameters: {'id': employeeId, 'name': position},
        );
      }
      await tx.execute(
        Sql.named(
          'update promotion_nominations '
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
        eventType: approve ? 'PromotionApproved' : 'PromotionRejected',
        payload: {
          'nominationId': id,
          'employeeId': employeeId,
          'proposedPosition': position,
          'raisePercent': rows.first[2],
          'note': note,
        },
      );
      return true;
    });
    if (!found) return null;
    final rows = await _db.query(
      'select n.*, e.family_name, e.given_name, e.photo_url '
      'from promotion_nominations n join employees e on e.id = n.employee_id '
      'where n.id = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    return _nomination(rows.first);
  }

  @override
  Future<Map<String, dynamic>> changePosition(
    String employeeId, {
    required String positionId,
    required bool promote,
    required String by,
    String? reason,
  }) => _db.transaction((tx) async {
    final rows = await tx.execute(
      Sql.named(
        'select e.status, e.position_id, p.name, coalesce(p.level, 1) '
        'from employees e left join positions p on p.id = e.position_id '
        'where e.id = @id for update of e',
      ),
      parameters: {'id': employeeId},
    );
    if (rows.isEmpty) {
      throw const OrganizationViolation('not_found', 'No such employee');
    }
    final current = rows.first;
    if (current[0] != 'active') {
      throw const OrganizationViolation('archived', 'Employee is archived');
    }
    final target = await tx.execute(
      Sql.named('select name, level from positions where id = @id'),
      parameters: {'id': positionId},
    );
    if (target.isEmpty) {
      throw const OrganizationViolation(
        'unknown_position',
        'Pick a position from the list',
      );
    }
    if (current[1] == positionId) {
      throw const OrganizationViolation(
        'same_position',
        'Employee already holds this position',
      );
    }
    final level = target.first[1]! as int;
    if (promote) {
      checkPromotion(currentLevel: current[3]! as int, targetLevel: level);
    }
    await tx.execute(
      Sql.named(
        'update employees set position_id = @position where id = @id',
      ),
      parameters: {'id': employeeId, 'position': positionId},
    );
    final change = {
      'employeeId': employeeId,
      'fromPosition': current[2],
      'positionId': positionId,
      'position': target.first[0],
      'level': level,
      'changedBy': by,
      'reason': reason,
    };
    await addOutboxEvent(
      tx,
      aggregate: 'employee',
      aggregateId: employeeId,
      eventType: promote ? 'EmployeePromoted' : 'PositionChanged',
      payload: change,
    );
    return change;
  });

  @override
  Future<Map<String, dynamic>> orgTree() async {
    final rows = await _db.query(
      'select e.id, e.family_name, e.given_name, e.photo_url, e.hired_on, '
      'e.department_id, p.name as position, coalesce(p.level, 1) as level, '
      'd.manager_id = e.id as is_head from employees e '
      'left join positions p on p.id = e.position_id '
      'left join departments d on d.id = e.department_id '
      "where e.status = 'active' order by level desc, e.family_name",
      fromPrimary: true,
    );
    final byDepartment = <String?, List<Map<String, dynamic>>>{};
    for (final r in rows) {
      (byDepartment[r['department_id'] as String?] ??= []).add({
        ..._person(r),
        'level': r['level'],
        // Trưởng phòng đứng trên cả phòng, tính như cấp 4 trở lên
        'isHead': r['is_head'] == true,
      });
    }
    return {
      'departments': [
        for (final d in await departments())
          {...d, 'people': byDepartment[d['id']] ?? const []},
      ],
      'unassigned': byDepartment[null] ?? const [],
    };
  }

  @override
  Future<List<Map<String, dynamic>>> positionsAbove(String employeeId) async {
    final rows = await _db.query(
      'select p.id, p.name, p.level from positions p '
      "where p.id not like 'GRP-%' "
      'and p.level > (select coalesce(c.level, 1) from employees e '
      'left join positions c on c.id = e.position_id where e.id = @id) '
      'order by p.level, p.name',
      params: {'id': employeeId},
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        {'id': r['id'], 'name': r['name'], 'level': r['level']},
    ];
  }

  Map<String, dynamic> _person(Map<String, dynamic> r) => {
    'id': r['id'],
    'name': '${r['family_name']} ${r['given_name']}',
    'photoUrl': media?.url(r['photo_url'] as String?),
    'position': r['position'],
    'hiredOn': (r['hired_on'] as DateTime?)?.toIso8601String().substring(0, 10),
  };

  Map<String, dynamic> _nomination(Map<String, dynamic> r) => {
    'id': r['id'],
    'employeeId': r['employee_id'],
    'employeeName': '${r['family_name']} ${r['given_name']}',
    'photoUrl': media?.url(r['photo_url'] as String?),
    'currentPosition': r['current_position'],
    'proposedPosition': r['proposed_position'],
    'raisePercent': double.tryParse('${r['raise_percent']}'),
    'reason': r['reason'],
    'status': r['status'],
    'nominatedBy': r['nominated_by'],
    'createdAt': (r['created_at'] as DateTime).toIso8601String(),
    'decidedBy': r['decided_by'],
    'note': r['note'],
    'scope': r['scope'] ?? 'region',
    'groupRole': r['group_role'],
  };
}
