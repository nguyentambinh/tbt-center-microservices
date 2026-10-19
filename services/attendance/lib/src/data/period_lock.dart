/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-16
 */

import 'package:attendance_service/src/domain/leave_request.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Saga chốt lương: khóa kỳ (semantic lock), không duyệt thêm đơn của kỳ đó
abstract interface class PeriodLocks {
  /// Khóa kỳ cho đợt chốt; gọi lại cùng đợt thì không sao
  Future<void> lock(String period, String runId);

  /// Mở khóa; chỉ đợt đã khóa mới mở được
  Future<void> unlock(String period, String runId);

  Future<Map<String, String>> locked();
}

class PostgresPeriodLocks implements PeriodLocks {
  PostgresPeriodLocks(this._db);

  final Database _db;

  @override
  Future<void> lock(String period, String runId) {
    return _db.transaction((tx) async {
      // Chờ các lệnh duyệt đang dở của kỳ này xong rồi mới khóa
      await tx.execute(
        Sql.named('select pg_advisory_xact_lock(hashtext(@key))'),
        parameters: {'key': 'period:$period'},
      );
      await tx.execute(
        Sql.named(
          'insert into period_locks (period, run_id) values (@period, @run) '
          'on conflict (period) do update set run_id = excluded.run_id, '
          'locked_at = now()',
        ),
        parameters: {'period': period, 'run': runId},
      );
    });
  }

  @override
  Future<void> unlock(String period, String runId) => _db.execute(
    'delete from period_locks where period = @period and run_id = @run',
    params: {'period': period, 'run': runId},
  );

  @override
  Future<Map<String, String>> locked() async {
    final rows = await _db.query(
      'select period, run_id from period_locks order by period',
      fromPrimary: true,
    );
    return {for (final r in rows) r['period'] as String: r['run_id'] as String};
  }
}

/// Trong giao dịch duyệt đơn: kỳ đang chốt lương thì từ chối
Future<void> ensurePeriodsOpen(
  TxSession tx,
  DateTime from,
  DateTime to,
) async {
  final periods = <String>{};
  for (
    var m = DateTime(from.year, from.month);
    !m.isAfter(DateTime(to.year, to.month));
    m = DateTime(m.year, m.month + 1)
  ) {
    periods.add('${m.year}-${m.month.toString().padLeft(2, '0')}');
  }
  for (final period in periods) {
    // Khóa chung: nhiều lệnh duyệt chạy song song được, lệnh khóa kỳ phải chờ
    await tx.execute(
      Sql.named('select pg_advisory_xact_lock_shared(hashtext(@key))'),
      parameters: {'key': 'period:$period'},
    );
  }
  final locked = await tx.execute(
    Sql.named('select period from period_locks where period = any(@periods)'),
    parameters: {'periods': TypedValue(Type.textArray, periods.toList())},
  );
  if (locked.isNotEmpty) {
    throw LeaveRuleViolation(
      'period_locked',
      'Payroll for ${locked.first[0]} is being closed, try again later',
    );
  }
}
