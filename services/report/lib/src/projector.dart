/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-15
 */

import 'dart:async';
import 'dart:io';

import 'package:report_service/src/doris_client.dart';
import 'package:tbt_common/tbt_common.dart';

/// Sự kiện đọc từ sổ audit ở Hub.
class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.region,
    required this.eventType,
    required this.payload,
    required this.occurredAt,
  });

  final int id;
  final String region;
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime occurredAt;
}

/// Đổi một sự kiện thành (bảng đọc, dòng); `null` nếu báo cáo không cần.
/// Hàm thuần, không gọi ra ngoài, để test dễ.
({String table, Map<String, Object?> row})? projectEvent(AuditEvent e) {
  final p = e.payload;
  final at = _doris(e.occurredAt);
  switch (e.eventType) {
    case 'PayrollRunCompleted':
      return (
        table: 'payroll_cost',
        row: {
          'run_id': p['runId'],
          'region': p['region'] ?? e.region,
          'period': p['period'],
          'employees': p['employees'],
          'currency': p['currency'],
          'total_net': p['totalNet'],
          'total_net_usd': p['totalNetUsd'],
          'updated_at': at,
        },
      );
    case 'LeaveRequested' || 'LeaveApproved' || 'LeaveRejected':
      return (
        table: 'leave_requests',
        row: {
          'leave_id': p['id'],
          'region': e.region,
          'employee_id': p['employeeId'],
          'from_date': p['fromDate'],
          'days': p['days'],
          'leave_type': p['leaveType'],
          'status': p['status'],
          'updated_at': at,
        },
      );
    case 'CandidateApplied' ||
        'CandidateProfileUpdated' ||
        'CandidateStatusChanged' ||
        'CandidateCvUploaded' ||
        'CandidateAnalyzed':
      return (
        table: 'candidates',
        row: {
          'candidate_id': p['candidateId'],
          'region': e.region,
          'country_code': p['countryCode'],
          'applied_position': p['appliedPosition'],
          'status': p['status'],
          'updated_at': at,
        },
      );
    // Điều kiện làm việc (R76, R77): giờ làm theo ca và tăng ca đã duyệt.
    case 'ClockedOut':
      return (
        table: 'work_hours',
        row: {
          'source_id': 'shift:${p['employeeId']}:${p['workDate']}',
          'region': e.region,
          'kind': 'shift',
          'employee_id': p['employeeId'],
          'work_date': p['workDate'],
          'hours': p['totalHours'],
          'overtime_hours': p['overtimeHours'],
          'updated_at': at,
        },
      );
    case 'OvertimeApproved' || 'OvertimeRejected':
      return (
        table: 'work_hours',
        row: {
          'source_id': 'overtime:${p['id']}',
          'region': e.region,
          'kind': 'overtime',
          'employee_id': p['employeeId'],
          'work_date': p['workDate'],
          'hours': 0,
          // Bị từ chối thì dòng cùng khóa được thay bằng 0 giờ.
          'overtime_hours': e.eventType == 'OvertimeApproved' ? p['hours'] : 0,
          'updated_at': at,
        },
      );
    case 'FinancePeriodClosed':
      return (
        table: 'finance_summary',
        row: {
          'region': e.region,
          'period': p['period'],
          'currency': p['currency'],
          'revenue': p['revenue'],
          'revenue_usd': p['revenueUsd'],
          'cost': p['cost'],
          'cost_usd': p['costUsd'],
          'updated_at': at,
        },
      );
    default:
      return null;
  }
}

String _doris(DateTime d) =>
    d.toUtc().toIso8601String().substring(0, 19).replaceFirst('T', ' ');

/// Bộ chiếu của CQRS: đọc sự kiện mới trong sổ audit (phía ghi), nạp vào
/// các bảng báo cáo ở Doris (phía đọc), lưu mốc đã chiếu tới đâu.
class Projector {
  Projector({
    required this.audit,
    required this.doris,
    this.batchSize = 500,
    this.onChanged,
  });

  final Database audit;
  final DorisClient doris;
  final int batchSize;

  /// Gọi khi mô hình đọc vừa đổi (để xóa cache)
  final Future<void> Function()? onChanged;
  bool _running = false;
  int? lastEventId;

  /// Lần chạy hiện tại, gắn vào nhãn Stream Load. Doris không nạp hai lần
  /// cùng một nhãn trong một lần chạy; khi dựng lại thì đổi lần chạy để nạp
  /// lại được. Bảng đọc đều là UNIQUE KEY nên nạp lại không sinh dòng trùng.
  String _run = '${DateTime.now().millisecondsSinceEpoch}';

  /// Dựng lại mô hình đọc từ đầu: đưa mốc về 0, lượt chiếu
  /// sau đọc lại toàn bộ sổ audit. Dùng khi thêm bảng đọc mới hay đổi cách
  /// tổng hợp; phía ghi ở các khu vực không bị ảnh hưởng.
  Future<void> rebuild() async {
    _run = '${DateTime.now().millisecondsSinceEpoch}';
    await doris.load(
      'projection_checkpoint',
      [
        {
          'name': 'audit',
          'last_event_id': 0,
          'updated_at': _doris(DateTime.now()),
        },
      ],
      label: 'rebuild_$_run',
    );
    lastEventId = 0;
    await onChanged?.call();
  }

  Future<int> _checkpoint() async {
    final rows = await doris.query(
      "select last_event_id from projection_checkpoint where name = 'audit'",
    );
    return rows.isEmpty ? 0 : (rows.first['last_event_id'] as num).toInt();
  }

  /// Chiếu một lô; trả số sự kiện đã xử lý.
  Future<int> projectOnce() async {
    final from = lastEventId ?? await _checkpoint();
    final rows = await audit.query(
      'select id, region, event_type, payload, occurred_at from events '
      'where id > @from order by id limit @limit',
      params: {'from': from, 'limit': batchSize},
    );
    if (rows.isEmpty) {
      lastEventId = from;
      return 0;
    }

    final byTable = <String, List<Map<String, Object?>>>{};
    for (final r in rows) {
      final projected = projectEvent(
        AuditEvent(
          id: r['id'] as int,
          region: r['region'] as String,
          eventType: r['event_type'] as String,
          payload: r['payload'] as Map<String, dynamic>,
          occurredAt: r['occurred_at'] as DateTime,
        ),
      );
      if (projected != null) {
        byTable.putIfAbsent(projected.table, () => []).add(projected.row);
      }
    }

    final first = rows.first['id'] as int;
    final last = rows.last['id'] as int;
    for (final entry in byTable.entries) {
      await doris.load(
        entry.key,
        entry.value,
        label: '${entry.key}_${first}_${last}_$_run',
      );
    }
    await doris.load(
      'projection_checkpoint',
      [
        {
          'name': 'audit',
          'last_event_id': last,
          'updated_at': _doris(DateTime.now()),
        },
      ],
      label: 'checkpoint_${first}_${last}_$_run',
    );
    lastEventId = last;
    return rows.length;
  }

  Timer? _pending;

  /// RabbitMQ báo có sự kiện thì chiếu sớm; gom các lần báo trong 1 giây
  /// thành một lần nạp, Doris không phải nhận quá nhiều lô nhỏ
  void kick() {
    _pending ??= Timer(const Duration(seconds: 1), () {
      _pending = null;
      unawaited(_runOnce());
    });
  }

  Timer start({Duration every = const Duration(seconds: 10)}) =>
      Timer.periodic(every, (_) => unawaited(_runOnce()));

  Future<void> _runOnce() async {
    if (_running) return;
    _running = true;
    try {
      var total = 0;
      int n;
      do {
        n = await projectOnce();
        total += n;
      } while (n == batchSize);
      if (total > 0) {
        stdout.writeln('Đã chiếu $total sự kiện vào Doris');
        await onChanged?.call();
      }
    } on Exception catch (e) {
      stderr.writeln('Chiếu sự kiện lỗi, lượt sau thử lại: $e');
    } finally {
      _running = false;
    }
  }
}
