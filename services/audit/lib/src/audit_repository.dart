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

  /// Đếm theo loại, khu vực, service, ngày, giờ địa phương; số bất thường
  Future<Map<String, dynamic>> stats(AuditFilter filter);

  Future<void> logAccess(AccessRecord record);

  Future<List<Map<String, dynamic>>> accessLog({int limit = 100});
}

/// Điều kiện tra cứu sổ kiểm toán.
class AuditFilter {
  const AuditFilter({
    this.region,
    this.eventType,
    this.from,
    this.to,
    this.service,
    this.anomaly,
    this.exactTime = false,
  });

  final String? region;
  final String? eventType;
  final DateTime? from;

  /// Tính tới hết ngày này (hoặc đúng thời điểm này khi [exactTime])
  final DateTime? to;
  final String? service;

  /// `after_hours`, `failure` hoặc `any`
  final String? anomaly;

  /// from/to có giờ phút: lọc đúng thời điểm thay vì cả ngày
  final bool exactTime;

  DateTime? get toExclusive =>
      to == null || exactTime ? to : DateTime(to!.year, to!.month, to!.day + 1);

  Map<String, Object?> toJson() => {
    'region': ?region,
    'eventType': ?eventType,
    'service': ?service,
    'anomaly': ?anomaly,
    'from': ?from?.toIso8601String().substring(0, exactTime ? 16 : 10),
    'to': ?to?.toIso8601String().substring(0, exactTime ? 16 : 10),
  };
}

/// Giờ địa phương của sự kiện theo múi giờ khu vực
const _localHour =
    'extract(hour from occurred_at at time zone case region '
    "when 'vn' then 'Asia/Ho_Chi_Minh' when 'de' then 'Europe/Berlin' "
    "when 'us' then 'America/New_York' when 'br' then 'America/Sao_Paulo' "
    "when 'za' then 'Africa/Johannesburg' when 'au' then 'Australia/Sydney' "
    "else 'UTC' end)";

/// Bất thường: thao tác lúc 22h–6h giờ địa phương, hoặc sự kiện thất bại,
/// bị từ chối, phải bù trừ, cần xử lý tay
const afterHoursSql = '($_localHour < 6 or $_localHour >= 22)';
const failureSql =
    "(event_type ~* '(fail|reject|compensat|attention|broken|error|returned)')";

const _filterSql =
    'where (@region::text is null or region = @region) '
    'and (@type::text is null or event_type = @type) '
    'and (@service::text is null or source_service = @service) '
    'and (@from::timestamptz is null or occurred_at >= @from::timestamptz) '
    'and (@to::timestamptz is null or occurred_at < @to::timestamptz) '
    "and (@anomaly::text is null or (@anomaly = 'after_hours' and "
    "$afterHoursSql) or (@anomaly = 'failure' and $failureSql) "
    "or (@anomaly = 'any' and ($afterHoursSql or $failureSql)))";

Map<String, Object?> _filterParams(AuditFilter f) => {
  'region': f.region,
  'type': f.eventType,
  'service': f.service,
  'from': f.from,
  'to': f.toExclusive,
  'anomaly': f.anomaly,
};

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
      'occurred_at, received_at, prev_hash, hash, '
      '$afterHoursSql as after_hours, $failureSql as failure from events '
      '$_filterSql order by id ${exportAll ? 'asc' : 'desc limit @limit'}',
      params: {..._filterParams(filter), if (!exportAll) 'limit': limit},
    );
    if (exportAll) return rows;
    return [
      for (final r in rows)
        {
          ..._json(r),
          'anomalies': [
            if (r['after_hours'] == true) 'after_hours',
            if (r['failure'] == true) 'failure',
          ],
        },
    ];
  }

  @override
  Future<Map<String, dynamic>> stats(AuditFilter filter) async {
    final params = _filterParams(filter);
    Future<List<Map<String, dynamic>>> group(String key, {int? top}) =>
        _db.query(
          'select $key as k, count(*)::int as n from events $_filterSql '
          'group by 1 order by ${top == null ? '1' : '2 desc'} '
          '${top == null ? '' : 'limit $top'}',
          params: params,
        );
    final totals = await _db.query(
      'select count(*)::int as total, '
      'count(*) filter (where $afterHoursSql)::int as after_hours, '
      'count(*) filter (where $failureSql)::int as failure '
      'from events $_filterSql',
      params: params,
    );
    List<Map<String, Object?>> pairs(List<Map<String, dynamic>> rows) => [
      for (final r in rows) {'key': '${r['k']}', 'count': r['n']},
    ];
    final byHour = List<int>.filled(24, 0);
    for (final r in await group('$_localHour::int')) {
      byHour[r['k'] as int] = r['n'] as int;
    }
    return {
      'total': totals.first['total'],
      'afterHours': totals.first['after_hours'],
      'failures': totals.first['failure'],
      'byType': pairs(await group('event_type', top: 15)),
      'byRegion': pairs(await group('region')),
      'byService': pairs(await group('source_service')),
      'byDay': pairs(await group("to_char(occurred_at, 'YYYY-MM-DD')")),
      'byLocalHour': byHour,
    };
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
