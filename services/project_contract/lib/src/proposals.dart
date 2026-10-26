/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-25
 */

import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:project_contract_service/src/data/project_repository.dart';
import 'package:project_contract_service/src/project_rules.dart';
import 'package:tbt_common/tbt_common.dart';

/// Bên lập đề xuất dự án (HR, tài chính, quản trị khu vực)
const proposerRoles = {'hr', 'finance'};

/// Bên duyệt
const approverRoles = {'executive'};

enum ProposalSide { proposer, executive }

/// Trạng thái kế tiếp khi [side] làm [action]. Bên nào sửa thì chờ bên kia
/// xác nhận; dự án chỉ được tạo khi bên còn lại đồng ý bản cuối.
String nextProposalStatus(String status, ProposalSide side, String action) {
  final next = switch ((side, status, action)) {
    (ProposalSide.executive, 'awaiting_executive', 'approve') => 'approved',
    (ProposalSide.executive, 'awaiting_executive', 'counter') =>
      'awaiting_proposer',
    (ProposalSide.executive, 'awaiting_executive', 'reject') => 'rejected',
    (ProposalSide.proposer, 'awaiting_proposer', 'approve') => 'approved',
    (ProposalSide.proposer, 'awaiting_proposer', 'counter') =>
      'awaiting_executive',
    (ProposalSide.proposer, 'awaiting_proposer', 'withdraw') => 'rejected',
    _ => null,
  };
  if (next == null) {
    throw ProjectRuleViolation(
      'invalid_proposal_action',
      'Cannot $action while proposal is $status',
    );
  }
  return next;
}

/// Số tiền viết kiểu Việt Nam, Đức (2.500.000,5) hoặc Anh (2,500,000.5)
double? parseAmount(String raw) {
  var s = raw.replaceAll(RegExp('[^0-9.,]'), '');
  final dot = s.lastIndexOf('.');
  final comma = s.lastIndexOf(',');
  if (dot >= 0 && comma >= 0) {
    // Dấu xuất hiện sau cùng là dấu thập phân
    final decimal = dot > comma ? '.' : ',';
    s = s.replaceAll(decimal == '.' ? ',' : '.', '').replaceAll(decimal, '.');
  } else {
    final sep = dot >= 0 ? '.' : (comma >= 0 ? ',' : null);
    if (sep != null) {
      final parts = s.split(sep);
      // Nhiều dấu, hoặc đúng 3 số phía sau: phân cách hàng nghìn
      final thousands = parts.length > 2 || parts.last.length == 3;
      s = thousands ? parts.join() : parts.join('.');
    }
  }
  return double.tryParse(s);
}

/// Nội dung đề xuất đã chuẩn hóa
class ProposalData {
  ProposalData(this.json);

  factory ProposalData.fromJson(Map<String, dynamic> raw) {
    String? text(String key) {
      final v = raw[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    double? number(String key) => switch (raw[key]) {
      final num n => n.toDouble(),
      final String s => parseAmount(s),
      _ => null,
    };

    String? day(String key) {
      final d = DateTime.tryParse(text(key) ?? '');
      return d?.toIso8601String().substring(0, 10);
    }

    return ProposalData({
      'name': text('name'),
      'customerName': text('customerName'),
      'customerType': text('customerType') == 'individual'
          ? 'individual'
          : 'company',
      'customerContact': text('customerContact'),
      'contractType': text('contractType'),
      'value': number('value'),
      'deposit': number('deposit'),
      'currency': text('currency')?.toUpperCase(),
      'startDate': day('startDate'),
      'endDate': day('endDate'),
      'acceptanceDate': day('acceptanceDate'),
      'companyId': text('companyId'),
      'memberIds': {
        for (final id in raw['memberIds'] as List? ?? const [])
          if (id is String && id.isNotEmpty) id,
      }.toList(),
    });
  }

  final Map<String, dynamic> json;

  String? get currency => json['currency'] as String?;
  List<String> get memberIds => (json['memberIds'] as List).cast<String>();

  DateTime? _day(String key) => DateTime.tryParse('${json[key]}');

  /// Mã lỗi theo luật dự án; thiếu tên, khách hàng cũng là lỗi
  List<String> errors({required double rateToUsd, required DateTime today}) => [
    if (json['name'] == null) 'name_required',
    if (json['customerName'] == null) 'customer_required',
    ...checkProposal(
      value: json['value'] as double?,
      deposit: json['deposit'] as double?,
      rateToUsd: rateToUsd,
      start: _day('startDate'),
      end: _day('endDate'),
      acceptance: _day('acceptanceDate'),
      members: memberIds.length,
      today: today,
    ),
  ];
}

/// Đề xuất sai luật: trả danh sách mã lỗi cho app hiện từng ô
class ProposalInvalid implements Exception {
  const ProposalInvalid(this.errors);

  final List<String> errors;
}

abstract interface class ProposalRepository {
  Future<List<Map<String, dynamic>>> list({String? status});

  Future<Map<String, dynamic>?> find(int id);

  Future<Map<String, dynamic>> create(
    ProposalData data, {
    required String by,
    String? contractKey,
    String? contractName,
    String? imageKey,
  });

  /// [data] khi sửa (counter); duyệt bản cuối thì tạo dự án
  Future<Map<String, dynamic>?> respond(
    int id, {
    required ProposalSide side,
    required String action,
    required String by,
    ProposalData? data,
    String? note,
  });

  /// Số dự án đang làm của từng nhân viên (để chia việc đều)
  Future<Map<String, int>> activeLoad();

  /// Đường dẫn hợp đồng gốc, ảnh công trình trong kho
  Future<({String? contract, String? image})> fileKeys(int id);
}

class PostgresProposalRepository implements ProposalRepository {
  PostgresProposalRepository(
    this._db, {
    required this.countryCode,
    required this.validate,
  });

  final Database _db;
  final String countryCode;

  /// Kiểm luật trước khi ghi (cần tỷ giá nên truyền từ ngoài vào)
  final Future<List<String>> Function(ProposalData data) validate;

  static const _columns =
      'id, status, data, version, contract_key, contract_name, image_key, '
      'created_by, decided_by, project_id, created_at, updated_at';

  @override
  Future<List<Map<String, dynamic>>> list({String? status}) async {
    final rows = await _db.query(
      'select $_columns from project_proposals '
      'where @status::text is null or status = @status '
      'order by updated_at desc limit 100',
      params: {'status': status},
      fromPrimary: true,
    );
    return [for (final r in rows) _json(r)];
  }

  @override
  Future<Map<String, dynamic>?> find(int id) async {
    final rows = await _db.query(
      'select $_columns from project_proposals where id = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    if (rows.isEmpty) return null;
    final events = await _db.query(
      'select action, actor, data, note, at from project_proposal_events '
      'where proposal_id = @id order by at, id',
      params: {'id': id},
      fromPrimary: true,
    );
    return {
      ..._json(rows.first),
      'events': [
        for (final e in events)
          {
            'action': e['action'],
            'actor': e['actor'],
            'data': e['data'],
            'note': e['note'],
            'at': (e['at'] as DateTime).toUtc().toIso8601String(),
          },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> create(
    ProposalData data, {
    required String by,
    String? contractKey,
    String? contractName,
    String? imageKey,
  }) async {
    final errors = await validate(data);
    if (errors.isNotEmpty) throw ProposalInvalid(errors);
    final id = await _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'insert into project_proposals (data, contract_key, contract_name, '
          'image_key, created_by) values (@data::jsonb, @contract, '
          '@contractName, @image, @by) returning id',
        ),
        parameters: {
          'data': jsonEncode(data.json),
          'contract': contractKey,
          'contractName': contractName,
          'image': imageKey,
          'by': by,
        },
      );
      final id = rows.first[0]! as int;
      await _event(tx, id, 'submitted', by, data: data.json);
      await _outbox(tx, id, 'ProjectProposed', data.json);
      return id;
    });
    return (await find(id))!;
  }

  @override
  Future<Map<String, dynamic>?> respond(
    int id, {
    required ProposalSide side,
    required String action,
    required String by,
    ProposalData? data,
    String? note,
  }) async {
    if (action == 'counter') {
      if (data == null) {
        throw const ProjectRuleViolation('data_required', 'Send the edits');
      }
      final errors = await validate(data);
      if (errors.isNotEmpty) throw ProposalInvalid(errors);
    }
    final found = await _db.transaction((tx) async {
      final rows = await tx.execute(
        Sql.named(
          'select status, data, contract_key, image_key from '
          'project_proposals where id = @id for update',
        ),
        parameters: {'id': id},
      );
      if (rows.isEmpty) return false;
      final current = rows.first.toColumnMap();
      final next = nextProposalStatus(
        current['status'] as String,
        side,
        action,
      );
      await tx.execute(
        Sql.named(
          'update project_proposals set status = @status, '
          'data = coalesce(@data::jsonb, data), '
          'version = version + case when @data::text is null then 0 else 1 '
          'end, decided_by = case when @final then @by else decided_by end, '
          'updated_at = now() where id = @id',
        ),
        parameters: {
          'id': id,
          'status': next,
          'data': data == null ? null : jsonEncode(data.json),
          'final': next == 'approved' || next == 'rejected',
          'by': by,
        },
      );
      await _event(
        tx,
        id,
        '${side.name}_$action',
        by,
        data: data?.json,
        note: note,
      );
      final latest = data?.json ?? _map(current['data']);
      switch (next) {
        case 'approved':
          final projectId = await _createProject(
            tx,
            latest,
            contractKey: current['contract_key'] as String?,
            imageKey: current['image_key'] as String?,
          );
          await tx.execute(
            Sql.named(
              'update project_proposals set project_id = @project '
              'where id = @id',
            ),
            parameters: {'id': id, 'project': projectId},
          );
          await _outbox(tx, id, 'ProjectProposalApproved', {
            ...latest,
            'projectId': projectId,
          });
        case 'rejected':
          await _outbox(tx, id, 'ProjectProposalRejected', latest);
        case 'awaiting_proposer':
          await _outbox(tx, id, 'ProjectProposalCountered', latest);
        default:
          await _outbox(tx, id, 'ProjectProposed', latest);
      }
      return true;
    });
    return found ? find(id) : null;
  }

  @override
  Future<({String? contract, String? image})> fileKeys(int id) async {
    final rows = await _db.query(
      'select contract_key, image_key from project_proposals where id = @id',
      params: {'id': id},
      fromPrimary: true,
    );
    if (rows.isEmpty) return (contract: null, image: null);
    return (
      contract: rows.first['contract_key'] as String?,
      image: rows.first['image_key'] as String?,
    );
  }

  @override
  Future<Map<String, int>> activeLoad() async {
    final rows = await _db.query(
      'select m.employee_id, count(distinct p.id)::int as n '
      'from project_members m '
      'join project_contracts pc on pc.id = m.project_contract_id '
      "join projects p on p.id = pc.project_id where p.status <> 'accepted' "
      'group by m.employee_id',
    );
    return {for (final r in rows) r['employee_id'] as String: r['n'] as int};
  }

  /// Tạo khách hàng (nếu mới), hợp đồng, dự án, thành viên trong cùng giao dịch
  Future<String> _createProject(
    TxSession tx,
    Map<String, dynamic> d, {
    String? contractKey,
    String? imageKey,
  }) async {
    final stamp = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
    final projectId = 'DA$stamp';
    final existing = await tx.execute(
      Sql.named(
        'select id from customers where lower(name) = lower(@name) '
        'and country_code = @country limit 1',
      ),
      parameters: {'name': d['customerName'], 'country': countryCode},
    );
    final customerId = existing.isEmpty
        ? 'KH$stamp'
        : existing.first[0]! as String;
    if (existing.isEmpty) {
      await tx.execute(
        Sql.named(
          'insert into customers (id, country_code, customer_type, name, '
          'contact) values (@id, @country, @type, @name, @contact)',
        ),
        parameters: {
          'id': customerId,
          'country': countryCode,
          'type': d['customerType'] ?? 'company',
          'name': d['customerName'],
          'contact': d['customerContact'],
        },
      );
    }
    final company =
        d['companyId'] as String? ??
        (await tx.execute(
              'select company_id from projects group by company_id '
              'order by count(*) desc limit 1',
            )).firstOrNull?[0]
            as String? ??
        'TBT$countryCode';
    await tx.execute(
      Sql.named(
        'insert into contracts (id, country_code, name, contract_type, '
        'start_date, expected_end_date, file_key) values (@id, @country, '
        '@name, @type, @start, @end, @file)',
      ),
      parameters: {
        'id': 'HD$stamp',
        'country': countryCode,
        'name': d['name'],
        'type': d['contractType'],
        'start': DateTime.parse(d['startDate'] as String),
        'end': DateTime.parse(d['endDate'] as String),
        'file': contractKey,
      },
    );
    await tx.execute(
      Sql.named(
        'insert into projects (id, company_id, country_code, customer_id, '
        'deposit_amount, expected_acceptance_amount, currency, image_key) '
        'values (@id, @company, @country, @customer, @deposit, @value, '
        '@currency, @image)',
      ),
      parameters: {
        'id': projectId,
        'company': company,
        'country': countryCode,
        'customer': customerId,
        'deposit': d['deposit'],
        'value': d['value'],
        'currency': d['currency'],
        'image': imageKey,
      },
    );
    await tx.execute(
      Sql.named(
        'insert into project_contracts (id, project_id, contract_id) '
        'values (@id, @project, @contract)',
      ),
      parameters: {
        'id': 'PC$stamp',
        'project': projectId,
        'contract': 'HD$stamp',
      },
    );
    for (final employee in d['memberIds'] as List? ?? const []) {
      await tx.execute(
        Sql.named(
          'insert into project_members (project_contract_id, employee_id, '
          'total_hours) values (@pc, @employee, 0) on conflict do nothing',
        ),
        parameters: {'pc': 'PC$stamp', 'employee': employee},
      );
    }
    await addOutboxEvent(
      tx,
      aggregate: 'project',
      aggregateId: projectId,
      eventType: 'ProjectCreated',
      payload: {
        'projectId': projectId,
        'value': d['value'],
        'currency': d['currency'],
        'members': (d['memberIds'] as List? ?? const []).length,
        'startDate': d['startDate'],
        'endDate': d['endDate'],
      },
    );
    return projectId;
  }

  Future<void> _event(
    TxSession tx,
    int id,
    String action,
    String actor, {
    Map<String, dynamic>? data,
    String? note,
  }) => tx.execute(
    Sql.named(
      'insert into project_proposal_events (proposal_id, action, actor, '
      'data, note) values (@id, @action, @actor, @data::jsonb, @note)',
    ),
    parameters: {
      'id': id,
      'action': action,
      'actor': actor,
      'data': data == null ? null : jsonEncode(data),
      'note': note,
    },
  );

  /// Sự kiện lên Hub: tên dự án, giá trị, không mang liên hệ khách hàng
  Future<void> _outbox(
    TxSession tx,
    int id,
    String type,
    Map<String, dynamic> d,
  ) => addOutboxEvent(
    tx,
    aggregate: 'project_proposal',
    aggregateId: '$id',
    eventType: type,
    payload: {
      'proposalId': id,
      'name': d['name'],
      'value': d['value'],
      'currency': d['currency'],
      'projectId': d['projectId'],
    },
  );

  Map<String, dynamic> _map(Object? v) => switch (v) {
    final Map<String, dynamic> m => m,
    final String s => jsonDecode(s) as Map<String, dynamic>,
    _ => <String, dynamic>{},
  };

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'status': r['status'],
    'data': _map(r['data']),
    'version': r['version'],
    'hasContract': r['contract_key'] != null,
    'contractName': r['contract_name'],
    'hasImage': r['image_key'] != null,
    'createdBy': r['created_by'],
    'decidedBy': r['decided_by'],
    'projectId': r['project_id'],
    'createdAt': (r['created_at'] as DateTime).toUtc().toIso8601String(),
    'updatedAt': (r['updated_at'] as DateTime).toUtc().toIso8601String(),
  };
}
