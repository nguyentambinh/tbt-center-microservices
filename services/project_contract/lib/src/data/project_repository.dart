/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

abstract interface class ProjectRepository {
  /// Danh sách dự án, tìm theo mã dự án, tên hợp đồng hoặc tên khách hàng.
  Future<({List<Map<String, dynamic>> items, int total})> projects({
    String? search,
    int limit = 20,
    int offset = 0,
  });

  /// `null` nếu không có dự án.
  Future<Map<String, dynamic>?> project(String id);

  /// Dự án nhân viên đang tham gia, kèm tổng giờ làm theo từng dự án (R38).
  Future<List<Map<String, dynamic>>> projectsOf(String employeeId);

  /// Đánh dấu đã nghiệm thu, phát `ProjectAccepted`. [recordRevenue] chạy
  /// trước khi ghi (gọi finance); nó lỗi thì dự án giữ nguyên trạng thái.
  /// `null` nếu không có dự án; ném [ProjectRuleViolation] `already_accepted`.
  Future<Map<String, dynamic>?> accept(
    String id, {
    required String acceptedBy,
    required DateTime acceptedOn,
    required Future<void> Function(String amount) recordRevenue,
  });
}

class ProjectRuleViolation implements Exception {
  const ProjectRuleViolation(this.code, this.message);

  final String code;
  final String message;
}

class PostgresProjectRepository implements ProjectRepository {
  PostgresProjectRepository(this._db);

  final Database _db;

  // Tên hiển thị của dự án lấy theo hợp đồng đầu tiên, vì bảng projects
  // của dữ liệu cũ không có cột tên.
  static const _summary = '''
select p.id, p.company_id, p.deposit_amount::text as deposit,
  p.expected_acceptance_amount::text as acceptance, p.currency,
  p.status, p.accepted_on,
  c.name as customer_name, c.customer_type,
  (select k.name from project_contracts pc
     join contracts k on k.id = pc.contract_id
    where pc.project_id = p.id order by k.start_date limit 1) as name,
  (select count(*) from project_contracts pc
     join project_members m on m.project_contract_id = pc.id
    where pc.project_id = p.id)::int as members
from projects p left join customers c on c.id = p.customer_id''';

  static const _filter = '''
where @search::text is null
   or p.id ilike @search or c.name ilike @search
   or exists (select 1 from project_contracts pc
                join contracts k on k.id = pc.contract_id
               where pc.project_id = p.id and k.name ilike @search)''';

  @override
  Future<({List<Map<String, dynamic>> items, int total})> projects({
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final pattern = search == null || search.isEmpty ? null : '%$search%';
    final rows = await _db.query(
      '$_summary $_filter order by p.id limit @limit offset @offset',
      params: {'search': pattern, 'limit': limit, 'offset': offset},
    );
    final count = await _db.query(
      'select count(*)::int as n from projects p '
      'left join customers c on c.id = p.customer_id $_filter',
      params: {'search': pattern},
    );
    return (
      items: [for (final r in rows) _summaryJson(r)],
      total: count.first['n'] as int,
    );
  }

  @override
  Future<Map<String, dynamic>?> project(String id) => _project(id);

  /// [fromPrimary] khi vừa ghi xong: replica có thể chưa kịp chép.
  Future<Map<String, dynamic>?> _project(
    String id, {
    bool fromPrimary = false,
  }) async {
    final rows = await _db.query(
      '$_summary where p.id = @id',
      params: {'id': id},
      fromPrimary: fromPrimary,
    );
    if (rows.isEmpty) return null;

    final customer = await _db.query(
      'select c.id, c.name, c.customer_type, c.contact, c.address '
      'from projects p join customers c on c.id = p.customer_id '
      'where p.id = @id',
      params: {'id': id},
      fromPrimary: fromPrimary,
    );
    final contracts = await _db.query(
      'select pc.id, k.id as contract_id, k.name, k.contract_type, '
      'k.start_date, k.expected_end_date, pc.end_date '
      'from project_contracts pc join contracts k on k.id = pc.contract_id '
      'where pc.project_id = @id order by k.start_date',
      params: {'id': id},
      fromPrimary: fromPrimary,
    );
    final members = await _db.query(
      'select m.project_contract_id, m.employee_id, '
      'm.total_hours::float8 as hours, m.project_salary::text as salary '
      'from project_contracts pc '
      'join project_members m on m.project_contract_id = pc.id '
      'where pc.project_id = @id order by m.employee_id',
      params: {'id': id},
      fromPrimary: fromPrimary,
    );

    final notices = await _db.query(
      'select channel, kind, status, created_at from customer_notices '
      'where project_id = @id order by created_at desc',
      params: {'id': id},
      fromPrimary: fromPrimary,
    );
    return {
      ..._summaryJson(rows.first),
      'customerNotices': [
        for (final n in notices)
          {
            'channel': n['channel'],
            'kind': n['kind'],
            'status': n['status'],
            'createdAt': (n['created_at'] as DateTime).toIso8601String(),
          },
      ],
      'customer': customer.isEmpty
          ? null
          : {
              'id': customer.first['id'],
              'name': customer.first['name'],
              'type': customer.first['customer_type'],
              'contact': customer.first['contact'],
              'address': customer.first['address'],
            },
      'contracts': [
        for (final c in contracts)
          {
            'id': c['id'],
            'contractId': c['contract_id'],
            'name': c['name'],
            'type': c['contract_type'],
            'startDate': _date(c['start_date']),
            'expectedEndDate': _date(c['expected_end_date']),
            'endDate': _date(c['end_date']),
          },
      ],
      'members': [
        for (final m in members)
          {
            'projectContractId': m['project_contract_id'],
            'employeeId': m['employee_id'],
            'hours': m['hours'],
            'projectSalary': m['salary'],
          },
      ],
    };
  }

  @override
  Future<List<Map<String, dynamic>>> projectsOf(String employeeId) async {
    final rows = await _db.query(
      'select p.id, k.name, k.start_date, pc.end_date, '
      'm.total_hours::float8 as hours '
      'from project_members m '
      'join project_contracts pc on pc.id = m.project_contract_id '
      'join projects p on p.id = pc.project_id '
      'join contracts k on k.id = pc.contract_id '
      'where m.employee_id = @id order by k.start_date desc',
      params: {'id': employeeId},
    );
    return [
      for (final r in rows)
        {
          'projectId': r['id'],
          'name': r['name'],
          'startDate': _date(r['start_date']),
          'endDate': _date(r['end_date']),
          'hours': r['hours'],
        },
    ];
  }

  /// Xếp hàng xác nhận gửi khách (R102): có email thì gửi email, không thì
  /// SMS theo số điện thoại; khách không có liên hệ thì bỏ qua.
  Future<void> _queueCustomerNotice(
    TxSession tx,
    String projectId, {
    required DateTime acceptedOn,
  }) async {
    final rows = await tx.execute(
      Sql.named(
        'select c.id, c.contact from projects p '
        'join customers c on c.id = p.customer_id where p.id = @id',
      ),
      parameters: {'id': projectId},
    );
    if (rows.isEmpty) return;
    final customerId = rows.first[0]! as String;
    final contact = (rows.first[1] as String?)?.trim() ?? '';
    if (contact.isEmpty) return;
    await tx.execute(
      Sql.named(
        'insert into customer_notices (project_id, customer_id, channel, '
        'recipient, kind, params) values (@project, @customer, @channel, '
        "@recipient, 'project_accepted', @params::jsonb)",
      ),
      parameters: {
        'project': projectId,
        'customer': customerId,
        'channel': contact.contains('@') ? 'email' : 'sms',
        'recipient': contact,
        'params': '{"acceptedOn": "${_date(acceptedOn)}"}',
      },
    );
  }

  Map<String, dynamic> _summaryJson(Map<String, dynamic> r) => {
    'id': r['id'],
    'name': r['name'],
    'companyId': r['company_id'],
    'customerName': r['customer_name'],
    'customerType': r['customer_type'],
    'deposit': r['deposit'],
    'expectedAcceptance': r['acceptance'],
    'currency': r['currency'],
    'members': r['members'],
    'status': r['status'],
    'acceptedOn': _date(r['accepted_on']),
  };

  @override
  Future<Map<String, dynamic>?> accept(
    String id, {
    required String acceptedBy,
    required DateTime acceptedOn,
    required Future<void> Function(String amount) recordRevenue,
  }) async {
    final updated = await _db.transaction((tx) async {
      // Khóa dự án: hai người bấm nghiệm thu cùng lúc chỉ một người qua.
      final found = await tx.execute(
        Sql.named(
          'select status, coalesce(expected_acceptance_amount, 0)::text '
          'from projects where id = @id for update',
        ),
        parameters: {'id': id},
      );
      if (found.isEmpty) return false;
      if (found.first[0] == 'accepted') {
        throw const ProjectRuleViolation(
          'already_accepted',
          'Project is already accepted',
        );
      }
      // finance chống ghi trùng theo mã dự án, nên lỗi ở đây rồi bấm lại vẫn
      // an toàn; giao dịch này rollback thì dự án vẫn "đang làm".
      final amount = found.first[1]! as String;
      await recordRevenue(amount);
      await tx.execute(
        Sql.named(
          "update projects set status = 'accepted', accepted_on = @day, "
          'accepted_by = @by where id = @id',
        ),
        parameters: {'id': id, 'day': acceptedOn, 'by': acceptedBy},
      );
      await _queueCustomerNotice(tx, id, acceptedOn: acceptedOn);
      await addOutboxEvent(
        tx,
        aggregate: 'project',
        aggregateId: id,
        eventType: 'ProjectAccepted',
        payload: {
          'projectId': id,
          'acceptedOn': _date(acceptedOn),
          'amount': amount,
        },
      );
      return true;
    });
    return updated ? _project(id, fromPrimary: true) : null;
  }

  String? _date(Object? value) =>
      value is DateTime ? value.toIso8601String().substring(0, 10) : null;
}
