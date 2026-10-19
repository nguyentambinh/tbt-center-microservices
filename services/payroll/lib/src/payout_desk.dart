/*
 * Họ tên: Nguyễn Tâm Bình
 * MSSV:   2324801030003
 * Môn:    Kiến trúc và thiết kế phần mềm
 * Bài:    Đồ án TBT Center đa quốc gia
 * Ngày:   2026-10-19
 */

import 'dart:async';
import 'dart:io';

import 'package:payroll_service/src/saga/payroll_saga.dart';
import 'package:postgres/postgres.dart';
import 'package:tbt_common/tbt_common.dart';

/// Phiếu lương một người trong kỳ, kèm số lần đã chuyển lại
class PayoutLine {
  const PayoutLine({
    required this.employeeId,
    required this.status,
    required this.net,
    required this.currency,
    this.paidOn,
    this.resent = 0,
  });

  final String employeeId;

  /// draft | paid
  final String status;
  final double net;
  final String currency;
  final DateTime? paidOn;
  final int resent;

  bool get paid => status == 'paid';

  /// Số lần tiền đã tới tay người nhận
  int get transfers => (paid ? 1 : 0) + resent;

  Map<String, dynamic> toJson({bool withAmount = true}) => {
    'employeeId': employeeId,
    'status': status,
    'net': withAmount ? net.toStringAsFixed(2) : null,
    'currency': currency,
    'paidOn': paidOn?.toIso8601String().substring(0, 10),
    'transfers': transfers,
  };
}

/// Một dòng nhật ký chuyển lương
class PayoutLogEntry {
  const PayoutLogEntry({
    required this.employeeId,
    required this.action,
    this.reference,
    this.bankReference,
    this.amount,
    this.currency,
    this.detail,
  });

  final String employeeId;

  /// paid | resent | skipped | duplicate_warning | failed | in_doubt
  final String action;
  final String? reference;
  final String? bankReference;
  final double? amount;
  final String? currency;
  final String? detail;
}

/// Gặp người đã nhận lương kỳ này thì: hỏi lại, bỏ qua, hay chuyển lại
enum DuplicateMode { ask, skip, resend }

sealed class PayoutOutcome {
  const PayoutOutcome();
}

/// Kỳ chưa có phiếu lương: phải chốt kỳ (Saga) trước
class NotCalculated extends PayoutOutcome {
  const NotCalculated();
}

/// Saga của kỳ đang chạy
class RunInProgress extends PayoutOutcome {
  const RunInProgress();
}

/// Đang có lượt chuyển khác cho kỳ này
class PayoutBusy extends PayoutOutcome {
  const PayoutBusy();
}

/// Có người đã nhận rồi, chưa chuyển gì, chờ người dùng chọn
class DuplicatesFound extends PayoutOutcome {
  const DuplicatesFound(this.duplicates, this.pending);

  final List<PayoutLine> duplicates;
  final int pending;
}

/// Đã nhận lệnh, đang chuyển ở nền; tiến độ ghi dần vào nhật ký
class PayoutAccepted extends PayoutOutcome {
  const PayoutAccepted({
    required this.count,
    required this.done,
    this.skipped = 0,
    this.missing = const [],
  });

  final int count;
  final int skipped;
  final List<String> missing;

  /// Xong khi chuyển hết hoặc dừng vì lỗi
  final Future<PayoutDone> done;

  Map<String, dynamic> toJson() => {
    'accepted': count,
    'skipped': skipped,
    'missing': missing,
  };
}

class PayoutDone extends PayoutOutcome {
  const PayoutDone({
    this.paid = 0,
    this.resent = 0,
    this.skipped = 0,
    this.failed = 0,
    this.missing = const [],
    this.failure,
  });

  final int paid;
  final int resent;
  final int skipped;
  final int failed;

  /// Mã nhân viên được chọn nhưng không có phiếu lương kỳ này
  final List<String> missing;

  /// Lý do dừng giữa chừng (kênh chi từ chối, quá hạn)
  final String? failure;

  Map<String, dynamic> toJson() => {
    'paid': paid,
    'resent': resent,
    'skipped': skipped,
    'failed': failed,
    'missing': missing,
  };
}

abstract interface class PayoutStore {
  /// Trạng thái đợt chốt của kỳ, `null` nếu chưa có đợt
  Future<String?> runStatus(String period);

  Future<List<PayoutLine>> lines(String period);

  /// Ghi nhật ký; dòng `paid` có mã ngân hàng thì đánh dấu phiếu đã chi
  Future<void> record(
    String period,
    String actor,
    List<PayoutLogEntry> entries,
  );

  Future<List<Map<String, dynamic>>> history(
    String period, {
    String? employeeId,
  });
}

/// Chuyển lương ngoài Saga: cả công ty, một nhóm người hoặc một người.
/// Người đã nhận rồi không chuyển lại, trừ khi chọn [DuplicateMode.resend].
class PayoutDesk {
  PayoutDesk({
    required this.store,
    required this.payout,
    this.payTimeout = const Duration(seconds: 50),
    this.chunkSize = 1,
    this.inDoubtRetries = 2,
  });

  final PayoutStore store;
  final PayoutSink payout;
  final Duration payTimeout;

  /// Số khoản mỗi lần gọi kênh chi, để mỗi lời gọi xong trong hạn chờ
  final int chunkSize;

  /// Số lần gửi lại cùng mã khi không rõ kênh chi đã chuyển chưa
  final int inDoubtRetries;

  final _busy = <String>{};

  Future<PayoutOutcome> transfer({
    required String period,
    required String actor,
    List<String>? employeeIds,
    DuplicateMode mode = DuplicateMode.ask,
  }) async {
    if (!_busy.add(period)) return const PayoutBusy();
    var background = false;
    try {
      final outcome = await _transfer(period, actor, employeeIds, mode);
      if (outcome is PayoutAccepted) {
        background = true;
        unawaited(outcome.done.whenComplete(() => _busy.remove(period)));
      }
      return outcome;
    } finally {
      if (!background) _busy.remove(period);
    }
  }

  Future<PayoutOutcome> _transfer(
    String period,
    String actor,
    List<String>? employeeIds,
    DuplicateMode mode,
  ) async {
    if (await store.runStatus(period) == 'running') {
      return const RunInProgress();
    }
    final all = await store.lines(period);
    final wanted = employeeIds?.toSet();
    final targets = wanted == null
        ? all
        : all.where((l) => wanted.contains(l.employeeId)).toList();
    if (targets.isEmpty) return const NotCalculated();
    final missing = wanted == null
        ? const <String>[]
        : (wanted.difference({for (final l in all) l.employeeId}).toList()
            ..sort());

    final duplicates = targets.where((l) => l.paid).toList();
    final pending = targets.where((l) => !l.paid).toList();
    if (duplicates.isNotEmpty && mode == DuplicateMode.ask) {
      await store.record(period, actor, [
        for (final d in duplicates)
          PayoutLogEntry(
            employeeId: d.employeeId,
            action: 'duplicate_warning',
            amount: d.net,
            currency: d.currency,
            detail: 'đã nhận ${d.transfers} lần',
          ),
      ]);
      return DuplicatesFound(duplicates, pending.length);
    }

    final skipped = mode == DuplicateMode.skip ? duplicates : <PayoutLine>[];
    final items = [
      for (final p in pending)
        (
          line: p,
          action: 'paid',
          ref: PayrollSaga.referenceFor(period, p.employeeId),
        ),
      if (mode == DuplicateMode.resend)
        for (final d in duplicates)
          (
            line: d,
            action: 'resent',
            // Mỗi lần chuyển lại một mã mới, không thì kênh chi coi là lệnh cũ
            ref: _resendReference(period, d),
          ),
    ];

    final entries = [
      for (final s in skipped)
        PayoutLogEntry(
          employeeId: s.employeeId,
          action: 'skipped',
          amount: s.net,
          currency: s.currency,
          detail: 'đã nhận ${s.transfers} lần, không chuyển lại',
        ),
    ];
    if (items.isEmpty) {
      await store.record(period, actor, entries);
      return PayoutDone(skipped: skipped.length, missing: missing);
    }
    await store.record(period, actor, entries);
    return PayoutAccepted(
      count: items.length,
      skipped: skipped.length,
      missing: missing,
      done: _execute(period, actor, items, skipped.length, missing),
    );
  }

  /// Chuyển từng nhóm [chunkSize] khoản, nhóm nào xong ghi nhật ký ngay;
  /// kênh chi lỗi thì dừng, các khoản còn lại ghi là chưa chuyển được
  Future<PayoutDone> _execute(
    String period,
    String actor,
    List<({PayoutLine line, String action, String ref})> items,
    int skipped,
    List<String> missing,
  ) async {
    var paid = 0;
    var resent = 0;
    var failed = 0;
    String? failure;
    try {
      for (var start = 0; start < items.length; start += chunkSize) {
        final chunk = items.sublist(
          start,
          start + chunkSize > items.length ? items.length : start + chunkSize,
        );
        var done = <String, String>{};
        String? doubt;
        if (failure == null) {
          // Quá hạn thì gửi lại đúng mã: kênh chi trả lệnh cũ, không chi lại
          for (var attempt = 0; attempt <= inDoubtRetries; attempt++) {
            try {
              done = await payout([
                for (final i in chunk)
                  (
                    reference: i.ref,
                    account: 'ACC-${i.line.employeeId}',
                    amount: i.line.net,
                    currency: i.line.currency,
                  ),
              ]).timeout(payTimeout);
              doubt = null;
              break;
            } on PayoutFailed catch (e) {
              done = e.paid;
              failure = e.reason;
              doubt = null;
              break;
            } on PayoutInDoubt catch (e) {
              doubt = e.reason;
            } on TimeoutException catch (e) {
              doubt = 'quá hạn: $e';
            }
          }
          if (doubt != null) failure = 'chưa rõ kết quả, cần đối soát: $doubt';
        }
        final entries = [
          for (final i in chunk)
            PayoutLogEntry(
              employeeId: i.line.employeeId,
              action: done[i.ref] != null
                  ? i.action
                  : doubt != null
                  ? 'in_doubt'
                  : 'failed',
              reference: i.ref,
              bankReference: done[i.ref],
              amount: i.line.net,
              currency: i.line.currency,
              detail: done[i.ref] == null ? failure : null,
            ),
        ];
        await store.record(period, actor, entries);
        for (final e in entries) {
          switch (e.action) {
            case 'paid':
              paid++;
            case 'resent':
              resent++;
            default:
              failed++;
          }
        }
      }
    } on Object catch (e) {
      // Lỗi ghi CSDL giữa chừng: dừng, phần đã ghi vẫn nằm trong nhật ký
      stderr.writeln('Chuyển lương kỳ $period dừng: $e');
      failure ??= '$e';
    }
    return PayoutDone(
      paid: paid,
      resent: resent,
      skipped: skipped,
      failed: failed,
      missing: missing,
      failure: failure,
    );
  }
}

String _resendReference(String period, PayoutLine line) =>
    '${PayrollSaga.referenceFor(period, line.employeeId)}-R${line.resent + 1}';

class PostgresPayoutStore implements PayoutStore {
  PostgresPayoutStore(this._db);

  final Database _db;

  @override
  Future<String?> runStatus(String period) async {
    final rows = await _db.query(
      'select status from payroll_runs where period = @period',
      params: {'period': period},
      fromPrimary: true,
    );
    return rows.isEmpty ? null : rows.first['status'] as String;
  }

  @override
  Future<List<PayoutLine>> lines(String period) async {
    final rows = await _db.query(
      'select p.employee_id, p.status, p.net_original::float8 as net, '
      'p.currency_original, p.paid_on, (select count(*) from payout_log l '
      'where l.period = p.period and l.employee_id = p.employee_id '
      "and l.action = 'resent')::int as resent from payslips p "
      'where p.period = @period order by p.employee_id',
      params: {'period': period},
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        PayoutLine(
          employeeId: r['employee_id'] as String,
          status: r['status'] as String,
          net: r['net'] as double,
          currency: r['currency_original'] as String,
          paidOn: r['paid_on'] as DateTime?,
          resent: r['resent'] as int,
        ),
    ];
  }

  @override
  Future<void> record(
    String period,
    String actor,
    List<PayoutLogEntry> entries,
  ) {
    if (entries.isEmpty) return Future.value();
    return _db.transaction((tx) async {
      for (final e in entries) {
        if (e.action == 'paid' && e.bankReference != null) {
          await tx.execute(
            Sql.named(
              "update payslips set status = 'paid', paid_on = current_date, "
              'bank_reference = @ref where period = @period '
              'and employee_id = @employee',
            ),
            parameters: {
              'ref': e.bankReference,
              'period': period,
              'employee': e.employeeId,
            },
          );
        }
        await tx.execute(
          Sql.named(
            'insert into payout_log (period, employee_id, action, source, '
            'reference, bank_reference, amount, currency, actor, detail) '
            "values (@period, @employee, @action, 'manual', @ref, @bankRef, "
            '@amount, @currency, @actor, @detail)',
          ),
          parameters: {
            'period': period,
            'employee': e.employeeId,
            'action': e.action,
            'ref': e.reference,
            'bankRef': e.bankReference,
            'amount': e.amount,
            'currency': e.currency,
            'actor': actor,
            'detail': e.detail,
          },
        );
        // Sổ audit ở Hub: ai làm gì với khoản của ai, không mang số tiền
        await addOutboxEvent(
          tx,
          aggregate: 'payout',
          aggregateId: '$period-${e.employeeId}',
          eventType: 'PayoutLogged',
          payload: {
            'period': period,
            'employeeId': e.employeeId,
            'action': e.action,
            'actor': actor,
          },
        );
      }
    });
  }

  @override
  Future<List<Map<String, dynamic>>> history(
    String period, {
    String? employeeId,
  }) async {
    final rows = await _db.query(
      'select employee_id, action, source, reference, amount::text, currency, '
      'actor, detail, at from payout_log where period = @period '
      'and (@employee::text is null or employee_id = @employee) '
      'order by id desc limit 300',
      params: {'period': period, 'employee': employeeId},
      fromPrimary: true,
    );
    return [
      for (final r in rows)
        {
          'employeeId': r['employee_id'],
          'action': r['action'],
          'source': r['source'],
          'reference': r['reference'],
          'amount': r['amount'],
          'currency': r['currency'],
          'actor': r['actor'],
          'detail': r['detail'],
          'at': (r['at'] as DateTime).toIso8601String(),
        },
    ];
  }
}
