/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

const genesisHash =
    '0000000000000000000000000000000000000000000000000000000000000000';

class IncomingEvent {
  const IncomingEvent({
    required this.eventId,
    required this.region,
    required this.sourceService,
    required this.outboxId,
    required this.aggregate,
    required this.aggregateId,
    required this.eventType,
    required this.payload,
    required this.occurredAt,
  });

  factory IncomingEvent.fromJson(Map<String, dynamic> json) => IncomingEvent(
    eventId: json['eventId'] as String,
    region: json['region'] as String,
    sourceService: json['sourceService'] as String,
    outboxId: json['outboxId'] as int,
    aggregate: json['aggregate'] as String,
    aggregateId: json['aggregateId'] as String,
    eventType: json['eventType'] as String,
    payload: json['payload'] as Map<String, dynamic>,
    occurredAt: DateTime.parse(json['occurredAt'] as String),
  );

  /// Mã duy nhất do khu vực sinh ra, Hub chống trùng theo mã này.
  final String eventId;
  final String region;
  final String sourceService;
  final int outboxId;
  final String aggregate;
  final String aggregateId;
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime occurredAt;
}

abstract interface class AuditRepository {
  /// Ghi các sự kiện mới, bỏ qua sự kiện đã có. Trả về số dòng ghi thêm.
  Future<int> append(List<IncomingEvent> events);

  Future<List<Map<String, dynamic>>> latest({int limit = 50, String? region});

  /// Sự kiện có id lớn hơn [after], cũ trước mới sau: cho bên đọc theo dòng
  /// sự kiện (notification) đọc tiếp từ chỗ đã dừng.
  Future<List<Map<String, dynamic>>> since(
    int after, {
    required String region,
    int limit = 200,
  });

  /// Tính lại toàn bộ chuỗi băm; trả id dòng đầu tiên bị sai, `null` nếu khớp.
  Future<({int checked, int? brokenAt})> verify();

  /// Tra cứu cho kiểm toán; mới nhất trước. [exportAll] lấy đủ cột băm, cũ
  /// trước mới sau, không giới hạn số dòng (để xuất tệp).
  Future<List<Map<String, dynamic>>> search(
    AuditFilter filter, {
    int limit = 100,
    bool exportAll = false,
  });

  Future<void> logAccess(AccessRecord record);

  Future<List<Map<String, dynamic>>> accessLog({int limit = 100});
}

/// Điều kiện tra cứu sổ kiểm toán.
class AuditFilter {
  const AuditFilter({this.region, this.eventType, this.from, this.to});

  final String? region;
  final String? eventType;
  final DateTime? from;

  /// Tính tới hết ngày này.
  final DateTime? to;

  Map<String, Object?> toJson() => {
    'region': ?region,
    'eventType': ?eventType,
    'from': ?from?.toIso8601String().substring(0, 10),
    'to': ?to?.toIso8601String().substring(0, 10),
  };
}

/// Một lần ai đó đọc, kiểm, xuất sổ kiểm toán (R90).
class AccessRecord {
  const AccessRecord({
    required this.userSub,
    required this.username,
    required this.roles,
    required this.action,
    this.filter = const AuditFilter(),
    this.rowCount,
    this.checksum,
  });

  final String userSub;
  final String username;
  final Set<String> roles;

  /// `search`, `verify` hoặc `export`.
  final String action;
  final AuditFilter filter;
  final int? rowCount;
  final String? checksum;
}

class PostgresAuditRepository implements AuditRepository {
  PostgresAuditRepository(this._db);

  final Database _db;

  /// Băm tính trong Postgres để lúc ghi và lúc kiểm tra dùng cùng công thức.
  static final _hashSql = [
    "encode(sha256(convert_to(@prev::text || '|' || @region || '|' || @service",
    "|| '|' || @outboxText || '|' || @type",
    "|| '|' || @payload::jsonb::text, 'UTF8')), 'hex')",
  ].join(' ');

  @override
  Future<int> append(List<IncomingEvent> events) {
    return _db.transaction((tx) async {
      // Một lúc chỉ một giao dịch nối chuỗi, để hai lô song song không cùng
      // lấy một prev_hash.
      await tx.execute('select pg_advisory_xact_lock(4242)');
      final last = await tx.execute(
        'select hash from events order by id desc limit 1',
      );
      var prev = last.isEmpty
          ? genesisHash
          : last.first.toColumnMap()['hash'] as String;

      var added = 0;
      for (final e in events) {
        final params = {
          'prev': prev,
          'region': e.region,
          'service': e.sourceService,
          'outboxText': e.outboxId.toString(),
          'type': e.eventType,
          'payload': jsonEncode(e.payload),
        };
        final inserted = await tx.execute(
          Sql.named(
            'insert into events (event_id, region, source_service, outbox_id, '
            'aggregate, aggregate_id, event_type, payload, occurred_at, '
            'prev_hash, hash) values (@eventId::uuid, @region, @service, '
            '@outboxId, '
            '@aggregate, @aggregateId, @type, @payload::jsonb, @occurredAt, '
            '@prev::text, $_hashSql) '
            'on conflict (event_id) do nothing '
            'returning hash',
          ),
          parameters: {
            ...params,
            'eventId': e.eventId,
            'outboxId': e.outboxId,
            'aggregate': e.aggregate,
            'aggregateId': e.aggregateId,
            'occurredAt': e.occurredAt,
          },
        );
        if (inserted.isNotEmpty) {
          prev = inserted.first.toColumnMap()['hash'] as String;
          added++;
        }
      }
      return added;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> latest({
    int limit = 50,
    String? region,
  }) async {
    final rows = await _db.query(
      'select id, region, source_service, event_type, aggregate_id, payload, '
      'occurred_at, received_at, hash from events '
      '${region == null ? '' : 'where region = @region '}'
      'order by id desc limit @limit',
      params: {'limit': limit, 'region': ?region},
    );
    return [for (final r in rows) _json(r)];
  }

  @override
  Future<List<Map<String, dynamic>>> search(
    AuditFilter filter, {
    int limit = 100,
    bool exportAll = false,
  }) async {
    final rows = await _db.query(
      'select id, region, source_service, event_type, aggregate_id, payload, '
      'occurred_at, received_at, prev_hash, hash from events '
      'where (@region::text is null or region = @region) '
      'and (@type::text is null or event_type = @type) '
      'and (@from::date is null or occurred_at >= @from::date) '
      "and (@to::date is null or occurred_at < @to::date + interval '1 day') "
      'order by id ${exportAll ? 'asc' : 'desc limit @limit'}',
      params: {
        'region': filter.region,
        'type': filter.eventType,
        'from': filter.from,
        'to': filter.to,
        if (!exportAll) 'limit': limit,
      },
    );
    return exportAll ? rows : [for (final r in rows) _json(r)];
  }

  @override
  Future<void> logAccess(AccessRecord record) async {
    await _db.execute(
      'insert into access_log (user_sub, username, roles, action, filters, '
      'row_count, checksum) values (@sub, @name, @roles, @action, '
      '@filters::jsonb, @rows, @checksum)',
      params: {
        'sub': record.userSub,
        'name': record.username,
        'roles': TypedValue(Type.textArray, record.roles.toList()),
        'action': record.action,
        'filters': jsonEncode(record.filter.toJson()),
        'rows': record.rowCount,
        'checksum': record.checksum,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> accessLog({int limit = 100}) async {
    final rows = await _db.query(
      'select id, username, roles, action, filters, row_count, checksum, '
      'accessed_at from access_log order by id desc limit @limit',
      params: {'limit': limit},
    );
    return [
      for (final r in rows)
        {
          'id': r['id'],
          'username': r['username'],
          'roles': r['roles'],
          'action': r['action'],
          'filters': r['filters'],
          'rowCount': r['row_count'],
          'checksum': r['checksum'],
          'accessedAt': (r['accessed_at'] as DateTime).toIso8601String(),
        },
    ];
  }

  Map<String, dynamic> _json(Map<String, dynamic> r) => {
    'id': r['id'],
    'region': r['region'],
    'sourceService': r['source_service'],
    'eventType': r['event_type'],
    'aggregateId': r['aggregate_id'],
    'payload': r['payload'],
    'occurredAt': (r['occurred_at'] as DateTime).toIso8601String(),
    'receivedAt': (r['received_at'] as DateTime).toIso8601String(),
    'hash': r['hash'],
  };

  @override
  Future<List<Map<String, dynamic>>> since(
    int after, {
    required String region,
    int limit = 200,
  }) async {
    final rows = await _db.query(
      'select id, region, source_service, event_type, aggregate_id, payload, '
      'occurred_at, received_at, hash, event_id::text from events '
      'where region = @region and id > @after order by id limit @limit',
      params: {'region': region, 'after': after, 'limit': limit},
    );
    return [
      for (final r in rows) {..._json(r), 'eventId': r['event_id']},
    ];
  }

  @override
  Future<({int checked, int? brokenAt})> verify() async {
    final rows = await _db.query(
      'select id, prev_hash, hash, region, source_service, outbox_id::text, '
      'event_type, payload::text as payload from events order by id',
    );
    var prev = genesisHash;
    for (final r in rows) {
      final expected = await _db.query(
        'select ${_hashSql.replaceAll('@payload::jsonb::text', '@payload')} '
        'as h',
        params: {
          'prev': prev,
          'region': r['region'],
          'service': r['source_service'],
          'outboxText': r['outbox_id'],
          'type': r['event_type'],
          'payload': r['payload'],
        },
      );
      if (r['prev_hash'] != prev || expected.first['h'] != r['hash']) {
        return (checked: rows.length, brokenAt: r['id'] as int);
      }
      prev = r['hash'] as String;
    }
    return (checked: rows.length, brokenAt: null);
  }
}
